# borrowed from https://github.com/joshmh/globalize2

require 'rubygems'
require 'minitest/autorun'

require 'active_record'

require 'active_support'
require 'active_support/test_case'

require 'mocha'

require 'globalize'
require 'permalink_fu'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

require File.expand_path(File.dirname(__FILE__) + '/data/models.rb')

class ActiveSupport::TestCase
  ActiveSupport.test_order = :random if ActiveSupport.respond_to?(:test_order)

  def reset_db!(schema_path = nil)
    ActiveRecord::Migration.verbose = false

    schema_path ||= File.expand_path(File.dirname(__FILE__) + '/data/schema.rb')
    load(schema_path)
  end

  def assert_member(item, array)
    assert_block "Item #{item} is not in array #{array}" do
      array.member?(item)
    end
  end

  def assert_belongs_to(model, associated)
    assert model.reflect_on_all_associations(:belongs_to).detect { |association|
      association.name.to_s == associated.to_s
    }
  end

  def assert_has_many(model, associated)
    assert model.reflect_on_all_associations(:has_many).detect { |association|
      association.name.to_s == associated.to_s
    }
  end

  def with_mocked_limit(model_class, column_name, limit)
    column = model_class.columns_hash[column_name]
    type = column.respond_to?(:cast_type) ? column.cast_type : column
    type = type.respond_to?(:sql_type_metadata) ? type.sql_type_metadata : type

    old = type.instance_variable_get(:@limit)
    type.instance_variable_set(:@limit, limit)
    yield
  ensure
    type.instance_variable_set(:@limit, old)
  end
end

module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def index_exists?(table_name, column_name)
        indexes(table_name).any? { |index| index.name == index_name(table_name, column_name) }
      end
    end
  end
end
