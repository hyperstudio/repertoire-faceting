require "cases/helper"

require "models/nobelist"

class NestedFacetTest < FacetingTestCase

  fixtures :nobelists, :affiliations
  passes   :unindexed, :indexed
    
  def setup
    @nobelists    = Arel::Table.new('nobelists')
    @affiliations = Arel::Table.new('affiliations')
    names = case(@pass)
    when :unindexed then []
    when :indexed then   Nobelist.facet_names
    end
    Nobelist.update_indexed_facets(names)
  end
    
  def test_drill
    sig  = Nobelist.facets[:birth_place].drill([])
    arel = @nobelists.group(:birth_country)
                     .project('birth_country', "signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
  end

  def test_refined_drill
    sig  = Nobelist.facets[:birth_place].drill(['British India'])
    arel = @nobelists.group(@nobelists[:birth_country], @nobelists[:birth_state])
                     .where(@nobelists[:birth_country].eq('British India'))
                     .project(@nobelists[:birth_state], "signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
      
    sig  = Nobelist.facets[:birth_place].drill(['British India', 'Punjab'])
    arel = @nobelists.group(@nobelists[:birth_country], @nobelists[:birth_state], @nobelists[:birth_city])
                     .where(@nobelists[:birth_country].eq('British India'))
                     .where(@nobelists[:birth_state].eq('Punjab'))
                     .project(@nobelists[:birth_city], "signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
  end
  
  def test_fully_refined_drill
    sig  = Nobelist.facets[:birth_place].drill(['British India', 'Punjab', 'Multan'])
    arel = @nobelists.group(@nobelists[:birth_country], @nobelists[:birth_state], @nobelists[:birth_city])
                     .where(@nobelists[:birth_country].eq('British India'))
                     .where(@nobelists[:birth_state].eq('Punjab'))
                     .where(@nobelists[:birth_city].eq('Multan'))
                     .project('NULL::TEXT', "signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
  end

  def test_empty_signature
    sig  = Nobelist.facets[:birth_place].signature([])
    arel = @nobelists.project("signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
  end

  def test_refined_signature
    sig  = Nobelist.facets[:birth_place].signature(['United States of America'])
    arel = @nobelists.where(@nobelists[:birth_country].eq('United States of America'))
                     .project("signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
    
    sig  = Nobelist.facets[:birth_place].signature(['United States of America', 'New York'])
    arel = @nobelists.where(@nobelists[:birth_country].eq('United States of America'))
                     .where(@nobelists[:birth_state].eq('New York'))
                     .project("signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
  end
  
  def test_fully_refined_signature
    sig  = Nobelist.facets[:birth_place].signature(['United States of America', 'New York', 'New York City'])
    arel = @nobelists.where(@nobelists[:birth_country].eq('United States of America'))
                     .where(@nobelists[:birth_state].eq('New York'))
                     .where(@nobelists[:birth_city].eq('New York City'))
                     .project("signature(nobelists.#{Nobelist.faceting_id})")

    assert_tuples arel, sig
  end
end