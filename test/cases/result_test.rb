require "cases/helper"
require "active_support/core_ext/exception"

require "models/nobelist"

class ResultTest < ActiveSupport::TestCase

  # N.B. the testing data file must be loaded before this test is run

  def test_result_refinements
    results = Nobelist.refine(:discipline => 'Economics')
    assert_equal 13, results.size
  end

  def test_result_base_refinements
    results = Nobelist.where("name like '%Robert%'").refine(:discipline => 'Economics')
    assert_equal 5, results.size
    results = Nobelist.where("name like '%Robert%'").refine(:discipline => 'Chemistry')
    assert_equal 2, results.size
  end

  def test_result_order_offset_limit
    results = Nobelist.refine(:discipline => 'Chemistry').order('nobel_year desc').offset(3).limit(1)
    assert_equal results.first.name, 'Mario J. Molina'
  end

  def test_result_nested_refinements
    results = Nobelist.refine(:birth_place => ["United States of America"])
    assert_equal 32, results.size
    results = Nobelist.refine(:birth_place => ["United States of America", "New York"])
    assert_equal 7, results.size
  end

  def test_result_refinement_joins
    results = Nobelist.refine(:degree => "S.M.")
    assert_equal 2, results.size
    
    results.each do |nobelist|
      nobelist.affiliations.each { |a| assert_equal a.degree, 'S.M.' }
    end
  end
end
