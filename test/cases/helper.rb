ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_record'

require 'repertoire-faceting'
require 'connection'


class MultiplePassTestCase < ActiveSupport::TestCase
  def passes
    [:default]
  end
  
  def run(*args)
    passes.inject(true) { |status, pass| @pass = pass; status && super }
  end
end

module TuplesTestHelper
  
  def assert_tuples(x, y)
    conn = ActiveRecord::Base.connection
    
    result = [x, y].map { |z| Set.new conn.select_rows(z.to_sql) }
    
    assert_equal(*result)
  end
  
end