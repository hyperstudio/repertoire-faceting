require "cases/helper"

require "models/nobelist"

class LifecycleTest < FacetingTestCase

  passes :once

  def setup
    @nobelists    = Arel::Table.new('nobelists')
    @affiliations = Arel::Table.new('affiliations')

    @facet_names = [ :discipline, :nobel_year, :degree, :birth_place, :birthdate, :birth_decade ]
  end


  def test_dropping_packed_ids
    Nobelist.index_facets([], 'id')

    assert Nobelist.faceting_id == 'id'
    assert Nobelist.signature_wastage > 0.9
  end

  def test_adding_packed_ids
    Nobelist.index_facets([], '_packed_id')

    assert Nobelist.faceting_id == '_packed_id'
    assert Nobelist.signature_wastage < 0.1
  end

  def test_default_without_indexes
    Nobelist.index_facets([])
    @facet_names.each { |att| refute Nobelist.facets[att].facet_indexed? }
  end

  def test_detect_indexes
    Nobelist.index_facets(@facet_names)
    @facet_names.each { |att| assert Nobelist.facets[att].facet_indexed? }
  end
end
