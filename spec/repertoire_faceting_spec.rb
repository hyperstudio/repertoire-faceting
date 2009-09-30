require File.dirname(__FILE__) + '/spec_helper'

class Nobelist
  include DataMapper::Resource
  
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
  property :imageUrl,       String, :length => 200
  property :imageCredit,    String, :length => 200

  has n, :affiliations
  
  is :faceted, :discipline,                   
               :nobel_year,
               :degree,
               :birthdate => :nested,         # default logic for this facet
               :birth_place => :nested
end

class Affiliation
  include DataMapper::Resource
  
  property :id,     Serial
  property :detail, String, :length => 200, :nullable => false
  property :degree, String
  property :year,   Integer
  
  belongs_to :nobelist
end


describe "Repertoire faceting" do
  
  before(:all) do
    # DataObjects::Postgres.logger = DataObjects::Logger.new(STDOUT, 0)
  end

  # N.B. the testing data file must be loaded before this spec is run
  
  describe "results" do

    it "should use filter refinements" do
      results = Nobelist.facet_results(:discipline => 'Economics')
      results.size.should == 13
    end

    it "should accept base and refinements mixed together" do
      results = Nobelist.facet_results(:name.like => '%Robert%', :discipline => 'Economics')
      results.size.should == 5
      results = Nobelist.facet_results(:name.like => '%Robert%', :discipline => 'Chemistry')
      results.size.should == 2
    end

    it "should accept chained base query and filter refinements" do
      results = Nobelist.all(:name.like => '%Robert%').facet_results(:discipline => 'Economics')
      results.size.should == 5
      results = Nobelist.all(:name.like => '%Robert%').facet_results(:discipline => 'Chemistry')
      results.size.should == 2
    end

    it "should be able to order, offset, and limit results" do
      results = Nobelist.facet_results(:discipline => 'Chemistry', :order => [:nobel_year.desc], :offset => 3, :limit => 1)
      results.first.name.should == 'Mario J. Molina'
    end

    it "should use arrays to represent nested facet values" do
      results = Nobelist.facet_results(:birth_place => ["United States of America"])
      results.size.should == 6
      results = Nobelist.facet_results(:birth_place => ["United States of America", "New York"])
      results.size.should == 1
    end

    it "should compute results for refinements on data from joined tables" do
      results = Nobelist.facet_results(:degree => "S.M.")
      results.size.should == 2
      
      results.each do |nobelist|
        nobelist.affiliations.each { |a| a.degree.should == 'S.M.' }
      end
    end

    it "should be able to refine on multiple facet values (AND-style by default)" do
      results = Nobelist.facet_results(:degree => ['Ph.D.', 'S.B.'])
      results.size.should == 3
    end

    it "should be able to switch between AND-style and OR-style for facets with multiple values" do
      results = Nobelist.facet_results(:degree => ['Ph.D.', 'S.B.'], :logic => {:degree => :and})
      results.size.should == 3
      
      results = Nobelist.facet_results(:degree => ['Ph.D.', 'S.B.'], :logic => {:degree => :or})
      results.size.should == 24
    end
    
  end

  describe "facet value counts" do

    it "should return value counts for an indexed facet" do
      expected = [['Physics', 27], ["Economics", 13], ["Chemistry", 12], ["Medicine/Physiology", 9], ["Peace", 2]]
      counts = Nobelist.facet_count('discipline')
      expected.sort.should == counts.sort
    end
    
    it "should allow ordering the facet value counts" do
      expected = [['Physics', 27], ["Economics", 13], ["Chemistry", 12], ["Medicine/Physiology", 9], ["Peace", 2]]
      counts = Nobelist.facet_count('discipline', :order => [:count.desc, :discipline.asc])
      counts.should == expected
      
      expected = [["Chemistry", 12], ["Economics", 13], ["Medicine/Physiology", 9], ["Peace", 2], ["Physics", 27]]
      counts = Nobelist.facet_count('discipline', :order => [:discipline.asc, :count.desc])
      counts.should == expected
    end
  
    it "should accommodate base queries" do
      expected = [["Economics", 5], ["Chemistry", 2], ["Physics", 2], ["Medicine/Physiology", 1]]
      counts = Nobelist.facet_count('discipline', :name.like => '%Robert%')
      counts.should == expected
  	end
    
    it "should allow minimum counts" do
      expected = [["Economics", 5]]
      counts = Nobelist.facet_count('discipline', :name.like => '%Robert%', :minimum => 3)
      counts.should == expected
  	end    
    
  	it "should accomodate prior facet refinements" do
      expected = [["Chemistry", 1], ["Economics", 1], ["Medicine/Physiology", 1]]
      counts = Nobelist.facet_count('discipline', :nobel_year => "1987")
      counts.should == expected
  	end
    
    it "should allow facet refinements via a variable" do
      query = {}
      query[:discipline] = [ "Medicine/Physiology" ]
      expected = [["1968", 1], ["1969", 1], ["1975", 1], ["1987", 1], ["1990", 1], ["1993", 1], ["2001", 1], ["2002", 1], ["2006", 1]]
      counts = Nobelist.facet_count('nobel_year', :refinements => query)
      counts.should == expected
    end

    it "should allow facet counts with a base query and refinements in a variable" do
      query = {}
      query[:discipline] = [ "Medicine/Physiology" ]
      expected = [["1993", 1]]      
      counts = Nobelist.facet_count('nobel_year', :birth_state => 'Kentucky', :refinements => query)
      counts.should == expected
    end  
  
    it "should allow drill-down in nested facet values" do
      expected = [[nil, 53], ["United States of America", 6], ["Germany", 2], ["England", 1], ["People's Republic of China", 1]]
      counts = Nobelist.facet_count(:birth_place)
      counts.should == expected

      expected = [["Connecticut", 1], ["Illinois", 1], ["Kentucky", 1], ["Massachusetts", 1], ["Nebraska", 1], ["New York", 1]]
      counts = Nobelist.facet_count(:birth_place, :birth_place => [ 'United States of America' ])
      counts.should == expected
    
      expected = [["New York City", 1]]
      counts = Nobelist.facet_count(:birth_place, :birth_place => [ 'United States of America', 'New York' ])
      counts.should == expected
    
      expected = [[nil, 1]]
      counts = Nobelist.facet_count(:birth_place, :birth_place => [ 'United States of America', 'New York', 'New York City' ])
      counts.should == expected
    end
    
    it "should allow drill-down in nested facet values using refinements in a variable" do
      query = {:birthdate => [ 1931, 3 ] }
      expected = [["22", 1]]
      counts = Nobelist.facet_count(:birthdate, :refinements => query)
      counts.should == expected
    end
    
    it "should allow facet value counts using data from joined tables" do
      expected = [[nil, 40], ["Ph.D.", 16], ["S.B.", 11], ["S.M.", 2]]
      counts = Nobelist.facet_count(:degree, :order => [:count.desc, :degree.asc])
      counts.should == expected
    end
    
  	it "should allow user to specity a facet value type" do
  	  expected = [[1985, 1], [2001, 1]]
  	  counts = Nobelist.facet_count(:nobel_year, :type => Integer, :discipline => 'Peace')
  	  counts.should == expected
  	end
  	
  	it "should allow user to specify whether to include null facet values" do
  	  expected = [[nil, 40], ["Ph.D.", 16], ["S.B.", 11], ["S.M.", 2]]
  	  counts = Nobelist.facet_count(:degree, :nullable => true)
  	  counts.should == expected
  	  
  	  expected = [["Ph.D.", 16], ["S.B.", 11], ["S.M.", 2]]
  	  counts = Nobelist.facet_count(:degree, :nullable => false)
  	  counts.should == expected
  	end

  end

end
