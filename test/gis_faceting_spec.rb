require File.dirname(__FILE__) + '/spec_helper'

require 'rexml/document'

class Nobelist
  include DataMapper::Resource
  
  property :id,             Serial
  property :discipline,     String
  property :last_name,      String, :nullable => false
  property :nobel_year,     Integer, :nullable => false
  
  is :faceted, :discipline,                   
               :nobel_year,	
               :birth_place     => :nested,  # textual nested facet
               :birthplace_geom => :geom     # nested GIS facet computed using PostGIS' ST_Within() function
end

# convenience function for accessing md5 checksums of GIS features in the facet index
def feature(label, layer)
  results = repository.adapter.query("SELECT birthplace_geom FROM _nobelists_birthplace_geom_facet WHERE label = ? AND layer = ?", label, layer)
  results.first
end


describe "Repertoire GIS faceting" do
  
  before(:all) do
    # DataObjects::Postgres.logger = DataObjects::Logger.new(STDOUT, 0)
  end

  # (a) the testing data file must be loaded before this spec is run
  # (b) because the textual facets hard code information we compute by GIS operations for the 
  #     geometry facets, use the former to check the latter
  # (c) feature() is a shorthand to make specs readable.  In practice one never needs it, since
  #     ordinary GIS faceting would refine one md5 checksum ids returned by prior calls to
  #     facet_count
  # (d) GIS renderers don't care about order of features, so the specs use to_set for equivalency  
  
  describe "results" do

    it "should use gis filter refinements to calculate results" do
      gis_results = Nobelist.facet_results(:birthplace_geom => feature('United States', 1)).to_set
      results     = Nobelist.facet_results(:birth_place     => [ 'United States of America' ] ).to_set
      
      gis_results.should == results
    end
    
    it "should do nesting queries based on GIS containment" do      
      gis_results = Nobelist.facet_results(:birthplace_geom => feature('Palo Alto', 2)).to_set
      results     = Nobelist.facet_results(:birth_place     => [ 'United States of America', 'California', 'Palo Alto' ] ).to_set
      
      gis_results.to_set.should == results.to_set
    end
    
    it "should facet using spatial logic rather than orthography" do
      nyc = Nobelist.facet_results(:birthplace_geom => feature('New York City', 2)).to_set

      manhattan = Nobelist.facet_results(:birth_place => [ 'United States of America', 'New York', 'New York City' ] ).to_set
      queens    = Nobelist.facet_results(:birth_place => [ 'United States of America', 'New York', 'Queens' ] ).to_set

      # spatial logic: queens and new york share point locations (... but who knows about brooklyn? :) )
      (nyc - queens).should == manhattan
    end
      
  end

  describe "facet value counts" do

    it "should return value counts for a GIS facet" do
      # N.B. results are not in orthographic order, since it's irrelevant to GIS mappers
      expected = [[feature('United States', 1), 32], [feature('United Kingdom', 1), 1], [feature('Mexico', 1), 1], 
                  [feature('Japan', 1), 1], [feature('Italy', 1), 1], [feature('Germany', 1), 1], [feature('Canada', 1), 1],
                  [feature('Russia', 1), 0], [feature('France', 1), 0]
                 ].to_set
      counts   = Nobelist.facet_count('birthplace_geom')
      counts   = counts.map{ |fv| fv[0..1] }.to_set
      
      counts.should == expected
    end

    it "should allow drill-down in nested facet values" do
      expected = [[feature('United States', 1), 32], [feature('United Kingdom', 1), 1], [feature('Mexico', 1), 1], 
                  [feature('Japan', 1), 1], [feature('Italy', 1), 1], [feature('Germany', 1), 1], [feature('Canada', 1), 1],
                  [feature('Russia', 1), 0], [feature('France', 1), 0]
                 ].to_set
      counts   = Nobelist.facet_count('birthplace_geom').to_set  
      counts   = counts.map{ |fv| fv[0..1] }.to_set
      counts.should == expected
      
      # TODO.  a more compelling example would add a states GIS layer in between countries and cities
      
      expected = [[feature('Rome', 2), 1]].to_set
      counts   = Nobelist.facet_count('birthplace_geom', :birthplace_geom => feature('Italy', 1)).to_set
      counts   = counts.map{ |fv| fv[0..1] }.to_set
      counts.should == expected
      
      expected = [].to_set
      counts   = Nobelist.facet_count('birthplace_geom', :birthplace_geom => feature('Rome', 2)).to_set
      counts   = counts.map{ |fv| fv[0..1] }.to_set
      counts.should == expected
    end
  end
end
