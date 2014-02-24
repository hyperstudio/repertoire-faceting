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
  
  def self.passes(*names)
    @@passes = names.flatten
  end

  def self.apis(*names)
    @@apis = names.flatten
  end

  def run(*args)
    @@apis.inject(true) do |status1, api|
      try_extension(api, status1) do
        @api = api
        @@passes.inject(status1) { |status2, name| @pass = name; status2 && super }
      end
    end
  end
  
  def try_extension(api, status, &block)
    conn   = ActiveRecord::Base.connection
    begin
      conn.execute("CREATE EXTENSION IF NOT EXISTS #{api}")
    rescue
      puts "\nSkipping API: #{api}"
      return status
    end
    # in a separate rescue block, or errors are silently ignored
    begin
      puts "\nLoaded API (#{api}); continuing to test"
      return yield
    ensure
      conn.execute("DROP EXTENSION IF EXISTS #{api} CASCADE")
    end
  end
  
  def assert_tuples(x, y)
    conn   = ActiveRecord::Base.connection
    result = [x, y].map { |z| Set.new conn.select_rows(z.to_sql) }
    refute_empty(result)
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