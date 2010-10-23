require "cases/helper"
require "active_support/core_ext/exception"

require "models/nobelist"

class BasicFacetTest < ActiveSupport::TestCase
  
  # comparing trees of relational algebra queries for equivalence is a hard problem, so
  # we run the queries and compare results as a shorthand
    
  def setup
    @nobelists    = Arel::Table.new('nobelists')
    @affiliations = Arel::Table.new('affiliations')
    
    Nobelist.update_indexed_facets([])
  end

  def test_signature
    sig  = Nobelist.facets[:discipline].drill([])
    arel = @nobelists.group('discipline').project('discipline', 'signature(_packed_id)')
    
    assert_tuples arel, sig
  end

  def test_joined_signature
    sig  = Nobelist.facets[:degree].drill([])
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .group('degree').project('degree', 'signature(_packed_id)')
    
    assert_tuples arel, sig
  end
  
  def test_refined_signature
    sig  = Nobelist.facets[:discipline].signature(['Economics'])
    arel = @nobelists.where(@nobelists[:discipline].eq('Economics')).project('signature(_packed_id)')

    assert_tuples arel, sig
  end
  
  def test_joined_refined_signature
    sig  = Nobelist.facets[:degree].signature(['Ph.D.'])
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .where(@affiliations[:degree].eq('Ph.D.')).project('signature(_packed_id)')
    
    assert_tuples arel, sig
  end

  def test_indexed_signature
    Nobelist.update_indexed_facets(:discipline)
    @discipline = Arel::Table.new('_nobelists_discipline_facet')

    sig  = Nobelist.facets[:discipline].drill([])
    arel = @discipline.project('discipline', 'signature')

    assert_tuples arel, sig
  end

  def test_indexed_refined_signature
    Nobelist.update_indexed_facets(:discipline)
    @discipline = Arel::Table.new('_nobelists_discipline_facet')
    
    sig  = Nobelist.facets[:discipline].signature(['Economics'])
    arel = @discipline.where(@discipline[:discipline].in(['Economics'])).project(@discipline[:signature])

    assert_tuples arel, sig
  end
  
  def test_facet_indexing
    Nobelist.update_indexed_facets(:discipline)
    
    arel1 = @nobelists.group('discipline').project('discipline', 'signature(_packed_id)')
    arel2 = Arel::Table.new('_nobelists_discipline_facet').project('discipline', 'signature')
    
    assert_tuples arel1, arel2, 'discipline'
  end
  
  def test_joined_facet_indexing
    Nobelist.update_indexed_facets(:degree)
    
    arel1 = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                      .group('degree').project('degree', 'signature(_packed_id)')
    arel2 = Arel::Table.new('_nobelists_degree_facet').project('degree', 'signature')
    
    assert_tuples arel1, arel2, 'degree'
  end
  
  private
  
  def assert_tuples(x, y, order_by='signature')
    conn = ActiveRecord::Base.connection
    
    x = conn.select_rows(x.order(order_by).to_sql)
    y = conn.select_rows(y.order(order_by).to_sql)
    
    assert_equal x, y
  end
  
end
