require File.dirname(__FILE__) + '/spec_helper'

class Nobelist
  include DataMapper::Resource
#  include DataMapper::Is::Faceted
  
  property :id,             Serial
  property :name,           String, :nullable => false
  property :birthdate,      DateTime
  property :birth_country,  String
  property :birth_state,    String
  property :birth_city,     String
  property :url,            String, :length => 200
  property :discipline,     String
  property :shared,         Boolean
  property :last_name,      String, :nullable => false
  property :nobel_year,     Integer, :nullable => false
  property :deceased,       Boolean
  property :co_winner,      String, :length => 200
  property :relationship_detail, String, :length => 200
  property :imageURL,       String, :length => 200
  property :imageCredit,    String, :length => 200

  is :faceted, :birthdate,
               :birth_place, 
               :discipline,
               :nobel_year
  # has n, :relationships, :through => DataMapper::Resource
end

class Relationship
  include DataMapper::Resource
  property :id,             Serial
  property :relationship_name, String, :length => 200, :nullable => false
end


describe "Repertoire faceting" do
  
  before(:all) do
    DataObjects::Postgres.logger = DataObjects::Logger.new(STDOUT, 0)
  end

  # N.B. the testing data file must be loaded before this spec is run

  describe "faceting results" do
 
    it "should use filter refinements to get results" do
      results = Nobelist.refine(:discipline => 'Economics')
      results.size.should == 13
    end

    it "should combine base query with filter refinements to get results" do
      results = Nobelist.all(:name.like => '%Robert%').refine(:discipline => 'Economics')
      results.size.should == 5
      results = Nobelist.all(:name.like => '%Robert%').refine(:discipline => 'Chemistry')
      results.size.should == 2
    end
  
    it "should be able to combine base query and refinements in any order" do      
      results = Nobelist.all(:name.like => '%Robert%').refine(:discipline => 'Chemistry')
      results.size.should == 2
    end
  
    it "should be able to refine on multiple facet values" do
      results = Nobelist.refine(:discipline => ['Chemistry', 'Economics'])
      results.size.should == 25
    end
  
    it "should be able to chain facet refinements" do
      results = Nobelist.refine(:discipline => 'Chemistry').refine(:discipline => 'Economics')
      results.size.should == 25
    end
    
    it "should use arrays to represent nested facet values" do
      results = Nobelist.refine(:birth_place => ["United States of America"])
      results.size.should == 6
      results = Nobelist.refine(:birth_place => ["United States of America", "New York"])
      results.should == [["New York City", 1]]

      # need to have some way to declare nested facets in the model
      # select birth_place[2], collect(signature) from _nobelists_birth_place_facet where birth_place[1] = 'United States of America' group by birth_place[2];
    end
    
    it "should be able to order, offset, and limit results" do
      results = Nobelist.refine(:discipline => 'Chemistry').all(:order => [:nobel_year.desc], :offset => 3, :limit => 1)
      results.first.name.should == 'Mario J. Molina'
    end
    
  end
  
  describe "facet value counts" do
    it "should return value counts for an indexed facet" do
      expected = [['Physics', 27], ["Economics", 13], ["Chemistry", 12], ["Medicine/Physiology", 9], ["Peace", 2]]
      counts = Nobelist.facet('discipline')
      expected.sort.should == counts.sort
    end
    
=begin    
    
    it "should allow ordering the facet value counts" do
      expected = [['Physics', 27], ["Economics", 13], ["Chemistry", 12], ["Medicine/Physiology", 9], ["Peace", 2]]
      counts = Nobelist.find_facet_counts(:facet => 'discipline', :order => :count)
      assert_equal expected, counts  
      expected = [["Chemistry", 12], ["Economics", 13], ["Medicine/Physiology", 9], ["Peace", 2], ["Physics", 27]]
      counts = Nobelist.find_facet_counts(:facet => 'discipline', :order => :alphanumeric)
      assert_equal expected, counts
    end
  
    it "test_base_condition" do
      expected = [["Economics", 5], ["Chemistry", 2], ["Physics", 2], ["Medicine/Physiology", 1]]
      counts = Nobelist.find_facet_counts(:conditions => "nobelists.name LIKE '%Robert%'", :facet => 'discipline')
      assert_equal expected, counts
  	end
	
  	it "test_refinements" do
      expected = [["Chemistry", 1], ["Economics", 1], ["Medicine/Physiology", 1]]
      counts = Nobelist.find_facet_counts(:facet => 'discipline', :filter => { :nobel_year => 1987 })
      assert_equal expected, counts
  	end
	
    it "test_facet_value_counting_from_query" do
      query = RepertoireFacets::Query.new

      query[:discipline] << "Medicine/Physiology"
      expected = [[1968, 1], [1969, 1], [1975, 1], [1987, 1], [1990, 1], [1993, 1], [2001, 1], [2002, 1], [2006, 1]]
      counts = Nobelist.find_facet_counts(query, :facet => :nobel_year)
      assert_equal expected, counts

      query[:birth_state] << "Kentucky"
      expected = [[1993, 1]]
      counts = Nobelist.find_facet_counts(query, :facet => :nobel_year)
      assert_equal expected, counts
    end
  
    it "test_nested_facet_value_counting" do
      expected = [[nil, 53], ["United States of America", 6], ["Germany", 2], ["England", 1], ["People's Republic of China", 1]]
      counts = Nobelist.find_facet_counts(:facet => [:birth_country, :birth_state, :birth_city], :filter => {})
      assert_equal expected, counts

      expected = [["Connecticut", 1], ["Illinois", 1], ["Kentucky", 1], ["Massachusetts", 1], ["Nebraska", 1], ["New York", 1]]
      counts = Nobelist.find_facet_counts(:facet => [:birth_country, :birth_state, :birth_city], 
                                          :filter => { :birth_country => 'United States of America' } )
      assert_equal expected, counts
    
      expected = [["New York City", 1]]
      counts = Nobelist.find_facet_counts(:facet => [:birth_country, :birth_state, :birth_city], 
                                          :filter => { :birth_country => 'United States of America', :birth_state => 'New York' } )
      assert_equal expected, counts
    
      expected = [["New York City", 1]]
      counts = Nobelist.find_facet_counts(:facet => [:birth_country, :birth_state, :birth_city], 
                                          :filter => { :birth_country => 'United States of America', :birth_state => 'New York', :birth_city => 'New York City' } )
      assert_equal expected, counts
    end
  
    it "test_nested_facet_value_counting_from_query" do
      query = RepertoireFacets::Query.new
      query[:birth_country] = ['United States of America']
      query[:birth_state] = ['New York']

      expected = [["New York City", 1]]
      counts = Nobelist.find_facet_counts(query, :facet => [:birth_country, :birth_state, :birth_city])
      assert_equal expected, counts
    end
  
    it "test_nested_facet_value_counting_from_query_with_filter_expansion" do
      query = RepertoireFacets::Query.new(:place => {:fields => [:birth_country, :birth_state, :birth_city]})
      query[:place] = ['United States of America', 'New York']
    
      expected = [["New York City", 1]]
      counts = Nobelist.find_facet_counts(query, :facet => :place)
      assert_equal expected, counts
    end
    
    it "test_computed_facet_value_counting" do
      expected = [["1906", 1], ["1910", 1], ["1912", 1], ["1918", 1], ["1920", 2], ["1921", 1], ["1922", 1], ["1928", 1], ["1929", 1], ["1930", 1], ["1931", 1], ["1939", 1], ["1940", 1], ["1941", 1], ["1943", 1], ["1944", 1], ["1945", 1], ["1949", 1], [nil, 44]]
      counts = Nobelist.find_facet_counts(:facet => 'EXTRACT(year FROM birthdate)', :order => :alphanumeric)
      assert_equal expected, counts
    end
  
    it "test_nested_computed_facet_value_counting" do
      expected = [["1906", 1], ["1910", 1], ["1912", 1], ["1918", 1], ["1920", 2], ["1921", 1], ["1922", 1], ["1928", 1], ["1929", 1], ["1930", 1], ["1931", 1], ["1939", 1], ["1940", 1], ["1941", 1], ["1943", 1], ["1944", 1], ["1945", 1], ["1949", 1], [nil, 44]]
      counts = Nobelist.find_facet_counts(:facet => ['EXTRACT(year FROM birthdate)', 'EXTRACT(month FROM birthdate)', 'EXTRACT(day FROM birthdate)'], :order => :alphanumeric, 
                                          :filter => {})
      assert_equal expected, counts
    
      expected = [["3", 1], ["9", 1]]
      counts = Nobelist.find_facet_counts(:facet => ['EXTRACT(year FROM birthdate)', 'EXTRACT(month FROM birthdate)', 'EXTRACT(day FROM birthdate)'], :order => :alphanumeric, 
                                          :filter => { 'EXTRACT(year FROM birthdate)' => 1920 })
      assert_equal expected, counts
    
      expected = [["14", 1]]
      counts = Nobelist.find_facet_counts(:facet => ['EXTRACT(year FROM birthdate)', 'EXTRACT(month FROM birthdate)', 'EXTRACT(day FROM birthdate)'], :order => :alphanumeric, 
                                          :filter => { 'EXTRACT(year FROM birthdate)' => 1920, 'EXTRACT(month FROM birthdate)' => 9 })
      assert_equal expected, counts
    end
  
    it "test_vocabulary_facet_value_counting" do
      expected = [["alumni", 25], ["professor", 25], ["research", 15], ["staff", 1], [nil, 1]]
      counts = Nobelist.find_facet_counts(:facet => :relationship_name, :vocabulary => :relationships, :filter => {})
      assert_equal expected, counts
    
      expected = [["alumni", 5], ["professor", 2], [nil, 1]]
      counts = Nobelist.find_facet_counts(:facet => :relationship_name, :vocabulary => :relationships, :filter => { :nobel_year => 2001 })
      assert_equal expected, counts
    end

=end
  end
end
