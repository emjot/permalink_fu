require 'yaml'
require 'digest/sha1'
require 'permalink_fu/version'

module PermalinkFu
  def has_permalink(attr_names = [], permalink_field = nil, options = {})
    if permalink_field.is_a?(Hash)
      options = permalink_field
      permalink_field = nil
    end
    ClassMethods.setup_permalink_fu_on self do
      self.permalink_attributes = Array(attr_names)
      self.permalink_field      = (permalink_field || 'permalink').to_s
      self.permalink_read_method  = [:read_attribute, self.permalink_field]
      self.permalink_write_method = [:write_attribute, self.permalink_field]
      self.permalink_class        = self
      if options[:globalize]
        unless self.respond_to?(:translations_table_name) && self.respond_to?(:translates)
          raise "globalize doesn't seem to be present"
        end
        are_any_pattrs_translated = self.permalink_attributes.any?{|a| self.translated_attribute_names.include?(a.to_sym)}
        is_permalink_translated   = self.translated_attribute_names.include?(self.permalink_field.to_sym)
        if are_any_pattrs_translated && !is_permalink_translated
          raise "permalink field should be translated if any of the permalink attributes are translated"
        end
        unless is_permalink_translated
          raise "permalink field needs to be translated if the :globalize option is used."
        end
        if self.translated_attribute_names.include?(self.permalink_field.to_sym)
          self.send :alias_method,      :"#{self.permalink_field}_translated",  :"#{self.permalink_field}"
          self.send :alias_method,      :"#{self.permalink_field}_translated=", :"#{self.permalink_field}="
          self.permalink_read_method  = [:"#{self.permalink_field}_translated"]
          self.permalink_write_method = [:"#{self.permalink_field}_translated="]
          self.permalink_class        = self.send :translation_class
        end
      end

      self.permalink_options    = {:unique => true}.update(options)
    end

    include InstanceMethods
  end

  class << self
    # This method does the actual permalink escaping.
    def escape(str)
      s = ClassMethods.decode(str)#.force_encoding("UTF-8")
      s.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
      s.gsub!(/[^\w_ \-]+/i,   '') # Remove unwanted chars.
      s.gsub!(/[ \-]+/i,      '-') # No more than one of the separator in a row.
      s.gsub!(/^\-|\-$/i,      '') # Remove leading/trailing separator.
      s.downcase!
      s.size == 0 ? ClassMethods.random_permalink(str) : s
    end
  end

  # Contains class methods for ActiveRecord models that have permalinks
  module ClassMethods
    # Contains Unicode codepoints, loading as needed from YAML files
    CODEPOINTS = Hash.new { |h, k|
      h[k] = YAML::load_file(File.join(File.dirname(__FILE__), "data", "#{k}.yml"))
    }

    class << self
      def decode(string)
        string.gsub(/[^\x00-\x7f]/u) do |codepoint|
          begin
            CODEPOINTS["x%02x" % (codepoint.unpack("U")[0] >> 8)][codepoint.unpack("U")[0] & 255]
          rescue
            "_"
          end
        end
      end

      def random_permalink(seed = nil)
        Digest::SHA1.hexdigest("#{seed}#{Time.now.to_s.split(//).sort_by {rand}}")
      end
    end

    def self.setup_permalink_fu_on(base)
      base.extend self
      class << base
        attr_accessor :permalink_options
        attr_accessor :permalink_attributes
        attr_accessor :permalink_field
        attr_accessor :permalink_read_method
        attr_accessor :permalink_write_method
        attr_accessor :permalink_class
      end

      yield

      if base.permalink_options[:unique]
        base.before_validation :create_unique_permalink
      else
        base.before_validation :create_common_permalink
      end
      class << base
        alias_method :define_attribute_methods_without_permalinks, :define_attribute_methods
        alias_method :define_attribute_methods, :define_attribute_methods_with_permalinks
      end unless base.respond_to?(:define_attribute_methods_without_permalinks)
    end

    def define_attribute_methods_with_permalinks
      if (value = define_attribute_methods_without_permalinks) && self.permalink_field
        class_eval <<-EOV
          def #{self.permalink_field}=(new_value);
            self.send(*(self.class.permalink_write_method + [new_value.blank? ? '' : PermalinkFu.escape(new_value)]));
          end
        EOV
      end
      value
    end
  end

  # This contains instance methods for ActiveRecord models that have permalinks.
  module InstanceMethods
  protected
    def create_common_permalink
      return unless should_create_permalink?
      if self.send(*self.class.permalink_read_method).blank? || permalink_fields_changed? || permalink_scope_fields_changed?
        send("#{self.class.permalink_field}=", create_permalink_for(self.class.permalink_attributes))
      end

      # Quit now if we have the changed method available and nothing has changed
      permalink_changed = "#{self.class.permalink_field}_changed?"
      return if respond_to?(permalink_changed) && !send(permalink_changed) && !permalink_scope_fields_changed?

      # Otherwise find the limit and crop the permalink
      limit   = self.class.permalink_class.columns_hash[self.class.permalink_field].limit
      base    = self.send("#{self.class.permalink_field}=", self.send(*self.class.permalink_read_method)[0..limit - 1])
      [limit, base]
    end

    def create_unique_permalink_without_globalize
      limit, base = create_common_permalink
      return if limit.nil? # nil if the permalink has not changed or :if/:unless fail
      counter = 1
      # oh how i wish i could use a hash for conditions
      conditions = ["#{self.class.permalink_field} = ?", base]
      unless new_record?
        conditions.first << " and id != ?"
        conditions       << id
      end
      if self.class.permalink_options[:scope]
        [self.class.permalink_options[:scope]].flatten.each do |scope|
          value = send(scope)
          if value
            conditions.first << " and #{scope} = ?"
            conditions       << send(scope)
          else
            conditions.first << " and #{scope} IS NULL"
          end
        end
      end
      while self.class.exists?(conditions)
        suffix = "-#{counter += 1}"
        conditions[1] = "#{base[0..limit-suffix.size-1]}#{suffix}"
        send("#{self.class.permalink_field}=", conditions[1])
      end
    end

    def create_unique_permalink # with globalize support # FIXME if there are untranslated attributes in permalink_attributes, the permalink also needs to be created for other languages!
      return create_unique_permalink_without_globalize() unless self.class.permalink_options && self.class.permalink_options[:globalize]
      # we can assume hereafter that the permalink field is translated

      # TODO check: works also if one language is present and we just created a new language version?
      # reload translations to get the actual translated_locales
      ActiveRecord::VERSION::MAJOR >= 5 ? self.translations.reload : self.translations(true)
      locales_to_create = (self.translated_locales + [Globalize.locale]).uniq

      locales_to_create.each do |locale|
        Globalize.with_locale(locale) do
          limit, base = create_common_permalink
          next if limit.nil? # nil if the permalink has not changed or :if/:unless fail

          counter = 1

          # add permalink field condition
          conditions = ["#{self.class.translations_table_name}.#{self.class.permalink_field} = ?", base]

          unless new_record?
            conditions.first << " and #{self.class.table_name}.id != ?"
            conditions       << id()
          end

          if self.class.permalink_options[:scope]
            [self.class.permalink_options[:scope]].flatten.each do |scope|
              table_name = self.class.translated_attribute_names.include?(scope.to_sym) ? self.class.translations_table_name : self.class.table_name
              value = send(scope)
              if value
                conditions.first << " and #{table_name}.#{scope} = ?"
                conditions       << send(scope)
              else
                conditions.first << " and #{table_name}.#{scope} IS NULL"
              end
            end
          end

          # scope by locale
          conditions.first << " and #{self.class.translations_table_name}.locale = ?"
          conditions       << locale.to_s

          # append counter just like the _without_globalize way (only we need to use count() instead of exists?())
          while 0 != self.class.joins(:translations).where(conditions).count
            suffix = "-#{counter += 1}"
            conditions[1] = "#{base[0..limit-suffix.size-1]}#{suffix}"
            send("#{self.class.permalink_field}=", conditions[1])
          end
        end
      end
    end

    def create_permalink_for(attr_names)
      str = attr_names.collect { |attr_name| send(attr_name).to_s } * " "
      str.blank? ? PermalinkFu::ClassMethods.random_permalink : str
    end

  private

    def should_create_permalink?
      if self.class.permalink_field.blank?
        false
      elsif self.class.permalink_options[:if]
        evaluate_method(self.class.permalink_options[:if])
      elsif self.class.permalink_options[:unless]
        !evaluate_method(self.class.permalink_options[:unless])
      else
        true
      end
    end

    # Don't even check _changed? methods unless :update is set
    def permalink_fields_changed?
      return false unless self.class.permalink_options[:update]
      self.class.permalink_attributes.any? do |attribute|
        changed_method = "#{attribute}_changed?"
        respond_to?(changed_method) ? send(changed_method) : true
      end
    end

    def permalink_scope_fields_changed?
      return false unless self.class.permalink_options[:update] && self.class.permalink_options[:scope]
      [*self.class.permalink_options[:scope]].any? do |attribute|
        changed_method = "#{attribute}_changed?"
        respond_to?(changed_method) ? send(changed_method) : true
      end
    end

    def evaluate_method(method)
      case method
      when Symbol
        send(method)
      when String
        eval(method, instance_eval { binding })
      when Proc, Method
        method.call(self)
      end
    end
  end
end

# Extend ActiveRecord functionality
ActiveSupport.on_load(:active_record) do
  extend PermalinkFu
end
