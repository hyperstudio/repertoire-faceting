require "cases/helper"
require "active_support/core_ext/exception"

require "models/nobelist"

class NestedFacetTest < ActiveSupport::TestCase
  
  # comparing trees of relational algebra queries for equivalence is a hard problem, so
  # we run the queries and compare results as a shorthand
    
  def setup
    @nobelists    = Arel::Table.new('nobelists')
    @affiliations = Arel::Table.new('affiliations')
    
    Nobelist.update_indexed_facets([])
  end
    
  def test_nested_signature
    sig  = Nobelist.facets[:birth_place].drill([])
    arel = @nobelists.group(:birth_country)
                     .project('birth_country', 'signature(_packed_id)')

    assert_tuples arel, sig
  end

  def test_nested_refined_signature
    sig  = Nobelist.facets[:birth_place].drill(['British India', 'Punjab'])
    arel = @nobelists.group(@nobelists[:birth_country], @nobelists[:birth_state], @nobelists[:birth_city])
                     .where(@nobelists[:birth_country].eq('British India'))
                     .where(@nobelists[:birth_state].eq('Punjab'))
                     .project(@nobelists[:birth_city], 'signature(_packed_id)')

    assert_tuples arel, sig
  end

  def test_indexed_nested_refined_signature
    Nobelist.update_indexed_facets(:birth_place)
    @birth_place = Arel::Table.new('_nobelists_birth_place_facet')
    
    sig  = Nobelist.facets[:birth_place].drill(['British India', 'Punjab'])
    arel = @birth_place.where(@birth_place[:birth_place1].eq('British India'))
                       .where(@birth_place[:birth_place2].eq('Punjab'))
                       .group(@birth_place[:birth_place1], @birth_place[:birth_place2], @birth_place[:birth_place3])
                       .project(@birth_place[:birth_place3], 'collect(signature) AS signature')

    assert_tuples arel, sig
  end  
  
  private
  
  def assert_tuples(x, y, order_by='signature')
    conn = ActiveRecord::Base.connection
    
    x = conn.select_rows(x.order(order_by).to_sql)
    y = conn.select_rows(y.order(order_by).to_sql)
    
    assert_equal x, y
  end
end