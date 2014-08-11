# borrowed from https://github.com/joshmh/globalize2

require 'rubygems'
require 'minitest/autorun'

require 'active_record'

require 'active_support'
require 'active_support/test_case'

require 'mocha'

require 'globalize'
require 'permalink_fu'

require File.expand_path(File.dirname(__FILE__) + '/data/models.rb')

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

class ActiveSupport::TestCase
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