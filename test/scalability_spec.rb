require File.dirname(__FILE__) + '/spec_helper'

require 'pp'

class Citizen
  include DataMapper::Resource
  
  property :id,             Serial
  property :first_name,     String
  property :last_name,      String
  property :gender,         String
  property :occupation,     String
  property :birth_city,     String
  property :birth_state,    String
  property :birthdate,      DateTime
	property :social_security, String
  
  is :faceted, :gender,                   
               :occupation,
               :birth_place => :nested,
               :birthdate => :nested
end

def time
  start = Time.now
  trace = yield
  elapsed = Time.now - start
  pp trace
  return elapsed
end

# keep in mind timings will vary with your machine... however the faceting module was designed to facet over
# a million items in acceptable times (< 0.5/2 second) for all of the tests below

describe "Repertoire faceting" do
  
  it 'should count facets likety-split: very small facet domain' do
    time { Citizen.facet_count(:gender) }.should < 0.5
  end
  
  it 'should count facets likety-split: medium facet domain' do
    time { Citizen.facet_count(:occupation) } < 0.5
  end
  
  it 'should count facets likety-split: drilling down nested facet domain' do
    time { Citizen.facet_count(:birth_place) } < 0.5
    time { Citizen.facet_count(:birth_place, :birth_place => ['New Mexico']) } < 0.5
  end
  
  it 'should count facets likety-split: simultaneous refinements' do
    time { Citizen.facet_count(:gender, :occupation => 'Dentist', :birth_place => ['New York', 'New York']) } < 0.5
  end  
  
end
