require "cases/helper"

require "models/nobelist"

class ResultTest < FacetingTestCase

  fixtures :nobelists, :affiliations
  passes   :unindexed, :partial1, :partial2, :indexed
  apis     ActiveRecord::Base.connection.api_bindings

  def setup
    names = case(@pass)
    when :unindexed then []
    when :partial1  then [:degree, :birth_place]
    when :partial2  then [:nobel_year, :birth_decade]
    when :indexed   then Nobelist.facet_names
    end
    Nobelist.update_indexed_facets(names)
  end

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
    results = Nobelist.refine(:discipline => 'Chemistry').order('nobel_year desc').offset(3).limit(2)
    
    assert_equal results[0].name, 'Mario J. Molina'
    assert_equal results[1].name, 'Elias J. Corey Jr.'
  end

  def test_result_refinement_joins
    results = Nobelist.refine(:degree => "S.M.")
    assert_equal 2, results.size

    results.each do |nobelist|
      nobelist.affiliations.each { |a| assert_equal a.degree, 'S.M.' }
    end
  end

  def test_result_nested_refinements
    results = Nobelist.refine(:birth_place => ["United States of America"])
    assert_equal 32, results.size
    results = Nobelist.refine(:birth_place => ["United States of America", "New York"])
    assert_equal 7, results.size    
    results = Nobelist.refine(:birth_place => [ 'United States of America', 'New York', 'New York City' ])
    assert_equal 4, results.size
  end

end
