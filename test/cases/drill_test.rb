require "cases/helper"
require "active_support/core_ext/exception"

require "models/nobelist"

class DrillTest < ActiveSupport::TestCase
  
  # comparing trees of relational algebra queries for equivalence is a hard problem, so
  # we run the queries and compare results as a shorthand
  
  # TODO.  find out why ordering on signature not always working
  
  def setup
    @nobelists    = Arel::Table.new('nobelists')
    @affiliations = Arel::Table.new('affiliations')
    
    @connection   = ActiveRecord::Base.connection
    @connection.update_indexed_facets(Nobelist, [])
  end

  def test_bare_mask
    masks = Nobelist.scoped.masks
    arel  = @nobelists.project('signature(_packed_id)')
    
    assert_equal 1, masks.size
    assert_tuples arel, masks.first
  end

  def test_drill
    sig  = Nobelist.discipline.drill([], false)
    arel = @nobelists.group('discipline').project('discipline', 'signature(_packed_id)')
    
    assert_tuples arel, sig
  end

  def test_joined_drill
    sig  = Nobelist.degree.drill([], false)
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .group('degree').project('degree', 'signature(_packed_id)')
    
    assert_tuples arel, sig
  end
  
  def test_refined_drill
    sig  = Nobelist.discipline.drill(['Economics'], true)
    arel = @nobelists.where(@nobelists[:discipline].eq('Economics')).project('signature(_packed_id)')

    assert_tuples arel, sig
  end
  
  def test_joined_refined_drill
    sig  = Nobelist.degree.drill(['Ph.D.'], true)
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .where(@affiliations[:degree].eq('Ph.D.')).project('signature(_packed_id)')
    
    assert_tuples arel, sig
  end
  
  def test_nested_drill
    sig  = Nobelist.birth_place.drill([], false)
    arel = @nobelists.group(:birth_country)
                     .project(:birth_country, 'signature(_packed_id)')

    assert_tuples arel, sig
  end

  def test_nested_refined_drill
    sig  = Nobelist.birth_place.drill(['British India', 'Punjab'], false)
    arel = @nobelists.group(:birth_city)
                     .where(@nobelists[:birth_country].eq('British India'))
                     .where(@nobelists[:birth_state].eq('Punjab'))
                     .project(:birth_city, 'signature(_packed_id)')
               
    assert_tuples arel, sig
  end
  
  def test_indexed_drill
    @connection.update_indexed_facets(Nobelist, [:discipline])
    @discipline = Arel::Table.new('_nobelists_discipline_facet')
    
    sig  = Nobelist.discipline.drill_indexed([], false)
    arel = @discipline.project('discipline', 'signature')

    assert_equal '_nobelists_discipline_facet', sig.relation.name
    assert_tuples arel, sig
  end
  
  def test_indexed_refined_drill
    @connection.update_indexed_facets(Nobelist, [:discipline])
    @discipline = Arel::Table.new('_nobelists_discipline_facet')
    
    sig  = Nobelist.discipline.drill_indexed(['Economics'], true)
    arel = @discipline.where(@discipline[:discipline].eq('Economics')).project('signature')

    assert_equal '_nobelists_discipline_facet', sig.relation.name
    assert_tuples arel, sig
  end

  def test_indexed_nested_refined_drill
    @connection.update_indexed_facets(Nobelist, [:birth_place])
    @birth_place = Arel::Table.new('_nobelists_birth_place_facet')
    
    sig  = Nobelist.birth_place.drill_indexed(['British India', 'Punjab'], false)
    arel = @birth_place.where(@birth_place[:birth_country].eq('British India'))
                       .where(@birth_place[:birth_state].eq('Punjab'))
                       .group(@birth_place[:birth_city])
                       .project(@birth_place[:birth_city], 'collect(signature) AS signature')
                       
    assert_equal '_nobelists_birth_place_facet', sig.relation.name

    assert_tuples arel, sig
  end
  
  def test_facet_indexing
    @connection.update_indexed_facets(Nobelist, [:discipline])
    
    arel1 = @nobelists.group('discipline').project('discipline', 'signature(_packed_id)')
    arel2 = Arel::Table.new('_nobelists_discipline_facet')
    
    assert_tuples arel1, arel2, 'discipline'
  end
  
  def test_joined_facet_indexing
    @connection.update_indexed_facets(Nobelist, [:degree])
    
    arel1 = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                      .group('degree').project('degree', 'signature(_packed_id)')
    arel2 = Arel::Table.new('_nobelists_degree_facet')
    
    assert_tuples arel1, arel2, 'degree'
  end
  
  private
  
  def assert_tuples(x, y, column='signature')
    x = x.order(column).map(&:tuple)
    y = y.order(column).map(&:tuple)
    assert_equal x, y
  end
  
end
