require "cases/helper"
require "active_support/core_ext/exception"

require "models/nobelist"

class CountTest < ActiveSupport::TestCase

  # N.B. the testing data file must be loaded before this test is run

  def test_count
    expected = {"Physics" => 27, "Economics" => 13, "Chemistry" => 12, "Medicine/Physiology" => 9, "Peace" => 2}
    counts = Nobelist.count(:discipline)
    assert_equal expected.sort, counts.sort
  end

  def test_count_ordering
    expected = {"Physics" => 27, "Economics" => 13, "Chemistry" => 12, "Medicine/Physiology" => 9, "Peace" => 2}
    counts = Nobelist.reorder('count desc', 'discipline asc').count(:discipline)
    assert_equal expected, counts
    
    expected = {"Chemistry" => 12, "Economics" => 13, "Medicine/Physiology" => 9, "Peace" => 2, "Physics" => 27}
    counts = Nobelist.reorder('discipline desc', 'count asc').count(:discipline)
    assert_equal expected, counts
  end

  def test_count_base
    expected = {"Economics" => 5, "Chemistry" => 2, "Physics" => 2, "Medicine/Physiology" => 1}
    counts = Nobelist.where("name like '%Robert%'").count(:discipline)
    assert_equal expected, counts
  end

  def test_count_minimum
    expected = {"Economics" => 5}
    counts = Nobelist.where("name like '%Robert%'").minimum(3).count(:discipline)
    assert_equal expected, counts
  end    
  
  def test_count_refinements_1
    expected = {"Chemistry" => 1, "Economics" => 1, "Medicine/Physiology" => 1}
    counts = Nobelist.refine(:nobel_year => "1987").count(:discipline)
    assert_equal expected, counts
  end
  
  def test_count_refinements_2
    query = {}
    query[:discipline] = [ "Medicine/Physiology" ]
    expected = {"1968" => 1, "1969" => 1, "1975" => 1, "1987" => 1, "1990" => 1, "1993" => 1, "2001" => 1, "2002" => 1, "2006" => 1}
    counts = Nobelist.refine(query).count(:nobel_year)
    assert_equal expected, counts
  end

  def test_count_base_refinements
    query = {}
    query[:discipline] = [ "Medicine/Physiology" ]
    expected = {"1993" => 1}
    
    counts = Nobelist.where(:birth_state => 'Kentucky').refine(query).count(:nobel_year)
    assert_equal expected, counts
  end

  def test_count_nested_signature
    expected = {"United States of America" => 32, nil => 15, "Germany" => 4, "Canada" => 3, "England" => 2, "British India"=> 1,
                "British Mandate of Palestine" => 1, "Italy" => 1, "Japan" => 1, "Korea" => 1, "Mexico"=> 1,
                "People's Republic of China" => 1}
    counts = Nobelist.count(:birth_place)
    assert_equal expected, counts

    expected = {"New York" => 7, "California" => 5, "Massachusetts" => 4, "Pennsylvania" => 3, "Illinois" => 2, 
                "Connecticut" => 1, "District of Columbia" => 1, "Florida" => 1, "Indiana" => 1, "Kentucky" => 1, "Michigan"=> 1,
                "Nebraska" => 1, "North Carolina" => 1, "South Carolina" => 1, "Virginia" => 1, "West Virginia" => 1}
    counts = Nobelist.refine(:birth_place => [ 'United States of America' ]).count(:birth_place)
    assert_equal expected, counts
  
    expected = {"New York City" => 4, "Brooklyn" => 1, "Mineola" => 1, "Queens" => 1}
    counts = Nobelist.refine(:birth_place => [ 'United States of America', 'New York' ]).count(:birth_place)
    assert_equal expected, counts
    
    expected = {nil => 4}
    counts = Nobelist.refine(:birth_place => [ 'United States of America', 'New York', 'New York City' ]).count(:birth_place)
    assert_equal expected, counts
  end
  
  def test_count_calculated
    expected = { "1896" => 1, "1898" => 1, "1904" => 1, "1906" => 1, "1907" => 1, "1910" => 1, "1912" => 2, "1913" => 1, "1915" => 4, 
                 "1917" => 1, "1918" => 3, "1920" => 2, "1921" => 2, "1922" => 1, "1924" => 1, "1926" => 1, "1928" => 2, "1929" => 1, 
                 "1930" => 2, "1931" => 2, "1932" => 1, "1933" => 1, "1936" => 1, "1937" => 1, "1938" => 2, "1939" => 4, "1940" => 1, 
                 "1941" => 2, "1942" => 1, "1943" => 2, "1944" => 2, "1945" => 2, "1947" => 3, "1948" => 1, "1949" => 1, "1950" => 1, 
                 "1951" => 2, "1957" => 1, "1959" => 1, "1961" => 1, nil => 1 }
    counts = Nobelist.count(:birthdate)
    assert_equal expected, counts
    
    expected = { "September" => 1, "May" => 1, "February" => 1, "October" => 1 }
    counts = Nobelist.refine(:birthdate => ["1939"]).count(:birthdate)
    assert_equal expected, counts
  end

  def test_count_joined
    expected = {nil => 40, "Ph.D." => 16, "S.B." => 11, "S.M." => 2}
    counts = Nobelist.reorder('count desc', 'degree asc').count(:degree)
    assert_equal expected, counts
  end
  
  def test_count_default_nils
	  expected = {nil => 40, "Ph.D." => 16, "S.B." => 11, "S.M." => 2}
	  counts = Nobelist.count(:degree)
	  assert_equal expected, counts
  end
	
  def test_count_no_nils
	  expected = {"Ph.D." => 16, "S.B." => 11, "S.M." => 2}
	  counts = Nobelist.nils(false).count(:degree)
	  assert_equal expected, counts
  end
  
end