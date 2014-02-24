require "cases/helper"

require "models/nobelist"

class BasicFacetTest < FacetingTestCase
  
  fixtures :nobelists, :affiliations
  passes   :unindexed, :indexed
  apis     ActiveRecord::Base.connection.api_bindings
    
  def setup
    
    puts ">>>> setup"
    
    @nobelists    = Arel::Table.new('nobelists')
    @affiliations = Arel::Table.new('affiliations')
    names = case(@pass)
    when :unindexed then []
    when :indexed   then [:discipline] # Nobelist.facet_names
    end
    
    puts "hello"
    
    unless names.empty?
      puts "renumbering"
      Nobelist.ensure_numbering('_packed_id')
      puts "reindexing"
      names.each { |name| Nobelist.facets[name].create_index('_packed_id'); puts "index for #{name}" }
    end
    
    # Nobelist.update_indexed_facets(names)
  end
  
  def test_drill
    sig  = Nobelist.facets[:discipline].drill([])
    arel = @nobelists.group('discipline').project('discipline', "facet.signature(nobelists.#{Nobelist.faceting_id})")
    
    assert_tuples arel, sig
  end
  
=begin
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
    Nobelist.update_indexed_facets([:discipline])
    
    arel1 = @nobelists.group('discipline').project('discipline', "facet.signature(nobelists.#{Nobelist.faceting_id})")
    arel2 = Arel::Table.new('facet._nobelists_discipline_facet').project('discipline', 'signature')
    
    assert_tuples arel1, arel2
  end
  
  def test_joined_indexing
    Nobelist.update_indexed_facets([:degree])
    
    arel1 = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                      .group('degree').project('degree', "facet.signature(nobelists.#{Nobelist.faceting_id})")
    arel2 = Arel::Table.new('facet._nobelists_degree_facet').project('degree', 'signature')
    
    assert_tuples arel1, arel2
  end
=end
  
end
