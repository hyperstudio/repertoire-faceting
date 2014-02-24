require "cases/helper"

require "models/nobelist"

class BasicFacetTest < FacetingTestCase
  
  passes   :unindexed, :simple, :nested

  def setup
    @nobelists    = Arel::Table.new('nobelists')
    @affiliations = Arel::Table.new('affiliations')
    names = case(@pass)
    when :unindexed then []
    when :simple    then [:discipline, :degree]
    when :nested    then [:birth_place, :birthdate]
    end
    Nobelist.index_facets(names)
  end
  
  def test_drill
    sig  = Nobelist.facets[:discipline].drill([])
    arel = @nobelists.group('discipline').project('discipline', "facet.signature(nobelists.#{Nobelist.faceting_id})")
    
    assert_tuples arel, sig
  end
  
  def test_joined_drill
    sig  = Nobelist.facets[:degree].drill([])
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .group('degree').project('degree', "facet.signature(nobelists.#{Nobelist.faceting_id})")
    
    assert_tuples arel, sig
  end
  
  def test_refined_signature
    sig  = Nobelist.facets[:discipline].signature(['Economics'])
    arel = @nobelists.where(@nobelists[:discipline].eq('Economics')).project("facet.signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
  end
  
  def test_joined_refined_signature
    sig  = Nobelist.facets[:degree].signature(['Ph.D.'])
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .where(@affiliations[:degree].eq('Ph.D.')).project("facet.signature(nobelists.#{Nobelist.faceting_id})")
    
    assert_tuples arel, sig
  end
  
  def test_indexing
    skip unless Nobelist.indexed_facets.include?(:discipline)
    
    arel1 = @nobelists.group('discipline').project('discipline', "facet.signature(nobelists.#{Nobelist.faceting_id})")
    arel2 = Arel::Table.new('facet._nobelists_discipline_facet').project('discipline', 'signature')
    
    assert_tuples arel1, arel2
  end
  
  def test_joined_indexing
    skip unless Nobelist.indexed_facets.include?(:degree)
    
    arel1 = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                      .group('degree').project('degree', "facet.signature(nobelists.#{Nobelist.faceting_id})")
    arel2 = Arel::Table.new('facet._nobelists_degree_facet').project('degree', 'signature')
    
    assert_tuples arel1, arel2
  end
  
end
