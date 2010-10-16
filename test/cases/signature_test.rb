require "cases/helper"
require "active_support/core_ext/exception"

require "models/nobelist"

class SignatureTest < ActiveSupport::TestCase
  
  # comparing trees of relational algebra queries for equivalence is a hard problem, so
  # we run the queries and compare results as a shorthand
  
  # TODO.  find out why ordering on signature not always wokring
  
  def setup
    @nobelists    = Arel::Table.new('nobelists')
    @affiliations = Arel::Table.new('affiliations')
    
    @connection   = ActiveRecord::Base.connection
    @connection.update_indexed_facets(Nobelist, [])
  end

  def test_base_signature
    sig  = Nobelist.signature
    arel = @nobelists.project('signature(_packed_id)')
    
    assert_tuples arel, sig
  end

  def test_facet_signature
    sig  = Nobelist.discipline.signature
    arel = @nobelists.group('discipline').project('discipline', 'signature(_packed_id)')
    
    assert_tuples arel, sig
  end

  def test_joined_facet_signature
    sig  = Nobelist.degree.signature
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .group('degree').project('degree', 'signature(_packed_id)')
    
    assert_tuples arel, sig
  end
  
  def test_refined_facet_signature
    sig  = Nobelist.discipline.signature('Economics')
    arel = @nobelists.where(@nobelists[:discipline].eq('Economics')).project('signature(_packed_id)')

    assert_tuples arel, sig
  end
  
  def test_joined_refined_facet_signature
    sig  = Nobelist.degree.signature('Ph.D.')
    arel = @nobelists.join(@affiliations).on(@nobelists[:id].eq(@affiliations[:nobelist_id]))
                     .where(@affiliations[:degree].eq('Ph.D.')).project('signature(_packed_id)')
    
    assert_tuples arel, sig
  end
  
  def test_nested_facet_signature
    sig  = Nobelist.birth_place.signature
    arel = @nobelists.group(:birth_country, :birth_state, :birth_city)
                     .project(:birth_country, :birth_state, :birth_city, 'signature(_packed_id)')

    assert_tuples arel, sig
  end

  def test_nested_refined_facet_signature
    sig  = Nobelist.birth_place.signature(['British India', 'Punjab'])
    arel = @nobelists.group(:birth_city)
                     .where(@nobelists[:birth_country].eq('British India'))
                     .where(@nobelists[:birth_state].eq('Punjab'))
                     .project('birth_city', 'signature(_packed_id)')
               
    assert_tuples arel, sig
  end
  
  def test_indexed_facet_signature
    @connection.update_indexed_facets(Nobelist, [:discipline])
    @discipline = Arel::Table.new('_nobelists_discipline_facet')
    
    sig  = Nobelist.discipline.signature
    arel = @discipline.project('discipline', 'signature')

    assert_equal '_nobelists_discipline_facet', sig.relation.name
    assert_tuples arel, sig
  end
  
  def test_indexed_refined_facet_signature
    @connection.update_indexed_facets(Nobelist, [:discipline])
    @discipline = Arel::Table.new('_nobelists_discipline_facet')
    
    sig  = Nobelist.discipline.signature(['Economics'])
    arel = @discipline.where(@discipline[:discipline].eq('Economics')).project('signature')

    assert_equal '_nobelists_discipline_facet', sig.relation.name
    assert_tuples arel, sig
  end

  def test_indexed_nested_refined_facet_signature
    @connection.update_indexed_facets(Nobelist, [:birth_place])
    @birth_place = Arel::Table.new('_nobelists_birth_place_facet')
    
    sig  = Nobelist.birth_place.signature(['British India', 'Punjab'])
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
