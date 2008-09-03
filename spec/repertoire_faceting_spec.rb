require File.dirname(__FILE__) + '/spec_helper'

class Project  
  include DataMapper::Resource
  property :id,                 Integer,  :serial   => true
  property :abbreviation,       String,   :nullable => false, :unique => true
  property :region,             String
  has n, :fields
end

class Field
  include DataMapper::Resource
  property :id,                 Integer,  :serial   => true
  property :field_name,         String,   :nullable => false
  belongs_to :project
end

describe "Repertoire faceting" do
  before(:all) do
    Project.auto_migrate!
    Field.auto_migrate!
  end
  
  it "should install an update trigger for each facet" do
    ber = Project.create(:abbreviation => 'ber', :region => 'Germany')    
    repository.adapter.query("SELECT count(*) FROM faceting.public_projects_region").should_be 1
  end
end
