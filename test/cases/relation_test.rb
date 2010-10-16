require "cases/helper"
require "active_support/core_ext/exception"

require "models/nobelist"

class RelationTest < ActiveSupport::TestCase
  
  def test_configure_facets_singly
    assert_raise Repertoire::Faceting::QueryError do
      Nobelist.degree.nobel_year
    end
  end
  
  def test_inherit_facet_refinements
    query    = Nobelist.refine(:degree => 'Ph.D', :discipline => 'Medicine').nobel_year.refine(:discipline => 'Economics')
    refines  = { :degree => [ 'Ph.D' ], :discipline => [ 'Medicine', 'Economics' ] }
    
    assert_equal refines, query.refine_value
  end
  
end