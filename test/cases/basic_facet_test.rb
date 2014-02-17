require "cases/helper"
#   require "active_support/core_ext/exception"

require "models/nobelist"

class BasicFacetTest < FacetingTestCase
  
  fixtures :nobelists, :affiliations
  passes :unindexed, :indexed
    
  def setup
    @nobelists    = Arel::Table.new('nobelists')
    @affiliations = Arel::Table.new('affiliations')
    names = case(@pass)
    when :unindexed then []
    when :indexed   then Nobelist.facet_names
    end
    Nobelist.update_indexed_facets(names)
  end

  def test_drill
    sig  = Nobelist.facets[:discipline].drill([])
    arel = @nobelists.group('discipline').project('discipline', "signature(nobelists.#{Nobelist.faceting_id})")
    
    assert_tuples arel, sig
  end

  def test_joined_drill
    sig  = Nobelist.facets[:degree].drill([])
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .group('degree').project('degree', "signature(nobelists.#{Nobelist.faceting_id})")
    
    assert_tuples arel, sig
  end
  
  def test_refined_signature
    sig  = Nobelist.facets[:discipline].signature(['Economics'])
    arel = @nobelists.where(@nobelists[:discipline].eq('Economics')).project("signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
  end
  
  def test_joined_refined_signature
    sig  = Nobelist.facets[:degree].signature(['Ph.D.'])
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .where(@affiliations[:degree].eq('Ph.D.')).project("signature(nobelists.#{Nobelist.faceting_id})")
    
    assert_tuples arel, sig
  end
  
  def test_indexing
    Nobelist.update_indexed_facets([:discipline])
    
    arel1 = @nobelists.group('discipline').project('discipline', "signature(nobelists.#{Nobelist.faceting_id})")
    arel2 = Arel::Table.new('_nobelists_discipline_facet').project('discipline', 'signature')
    
    assert_tuples arel1, arel2
  end
  
  def test_joined_indexing
    Nobelist.update_indexed_facets([:degree])
    
    arel1 = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                      .group('degree').project('degree', "signature(nobelists.#{Nobelist.faceting_id})")
    arel2 = Arel::Table.new('_nobelists_degree_facet').project('degree', 'signature')
    
    assert_tuples arel1, arel2
  end
  
end
