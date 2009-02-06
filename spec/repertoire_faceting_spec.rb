require File.dirname(__FILE__) + '/spec_helper'

class Project  
  include DataMapper::Resource
  property :id,                 Integer,  :serial   => true
  property :abbreviation,       String,   :nullable => false, :unique => true
  property :region,             String
  has n, :fields
  
  is :faceted, :region, 
               :field
end

class Field
  include DataMapper::Resource
  property :id,                 Integer,  :serial   => true
  property :field_name,         String,   :nullable => false
  belongs_to :project
end

def reindex_facets
  # normally this would be done by crontab
  repository(:default).adapter.execute <<SQL
    SELECT renumber_table('projects', '_packed_id');
    SELECT recreate_table('_projects_region_facet', 'SELECT region, signature(_packed_id) FROM projects GROUP BY region');
    SELECT recreate_table('_projects_field_facet', 
     'SELECT field_name AS field, signature(_packed_id) FROM projects JOIN fields ON projects.id = project_id GROUP BY field_name');
SQL
end

describe "Repertoire faceting" do
  before(:all) do
    Project.auto_migrate!
    Field.auto_migrate!
  end
  
  it "should index the regions facet" do
    ber = Project.create(:abbreviation => 'ber', :region => 'Germany')
    reindex_facets
    Project.facet_count(:region).should == ['Germany', 1]
  end
end
