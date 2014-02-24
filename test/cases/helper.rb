ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_record'

require 'repertoire-faceting'
require 'connection'

require 'config'

class FacetingTestCase < ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  self.fixture_path = FIXTURES_ROOT
  self.use_instantiated_fixtures  = false
  self.use_transactional_fixtures = true

  def create_fixtures(*table_names, &block)
    Fixtures.create_fixtures(FacetingTestCase.fixture_path, table_names, {}, &block)
  end
  
  def self.passes(*names)
    @@passes = names.flatten
  end
  
  def run(*args)
    conn   = ActiveRecord::Base.connection
    apis   = conn.api_bindings
    
    conn.execute('CREATE SCHEMA IF NOT EXISTS "test_schema"')
    done = apis.inject(true) do |result, api|
      begin
        conn.execute("CREATE EXTENSION IF NOT EXISTS #{api}")
        puts "\nLoaded #{api}"
        loaded = true
      rescue 
        puts "\nCould not load #{api}"
        loaded = false
      end  
      if loaded
        result &&= @@passes.inject(true) do |status, name| 
          @pass = name
          status && super
        end
      else
        result = false
      end
      conn.execute("DROP EXTENSION IF EXISTS #{api}")
      
      result
    end
    conn.execute('DROP SCHEMA "test_schema" CASCADE')
    
    done
  end
  
  def assert_tuples(x, y)
    conn   = ActiveRecord::Base.connection
    result = [x, y].map { |z| Set.new conn.select_rows(z.to_sql) }
    assert_equal(*result)
  end
  
end

# silence verbose schema loading
original_stdout = $stdout
$stdout = StringIO.new

begin
  adapter_name = ActiveRecord::Base.connection.adapter_name.downcase
  adapter_specific_schema_file = SCHEMA_ROOT + "/#{adapter_name}_specific_schema.rb"

  load SCHEMA_ROOT + "/schema.rb"

  if File.exist?(adapter_specific_schema_file)
    load adapter_specific_schema_file
  end
ensure
  $stdout = original_stdout
end