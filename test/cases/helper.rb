ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'minitest/autorun'
require 'active_support'
require 'active_record'

require 'repertoire-faceting'
require 'connection'

require 'config'

class FacetingTestCase < ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures        = true
  self.use_transactional_fixtures = true             # important - DDL use in model.rb
                                                     # interferes with Rails' transactional tests

  # N.B. the testing data file must be loaded before tests are run

  def self.passes(*names)
    @@passes = names.flatten
  end

  def run(*args)
    @@passes.inject(true) { |status, name| @pass = name; status && super }
  end
  
  def assert_tuples(x, y)
    conn   = ActiveRecord::Base.connection
    result = [x, y].map { |z| Set.new conn.select_rows(z.to_sql) }
    refute_empty(result)
    assert_equal(*result)
  end
  
end
