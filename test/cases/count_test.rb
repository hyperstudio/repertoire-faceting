require "cases/helper"
require "active_support/core_ext/exception"

require "models/nobelist"

class CountTest < ActiveSupport::TestCase

  # N.B. the testing data file must be loaded before this test is run

  def test_count
    expected = {"Physics" => 27, "Economics" => 13, "Chemistry" => 12, "Medicine/Physiology" => 9, "Peace" => 2}
    counts = Nobelist.discipline.count
    assert_equal expected.sort, counts.sort
  end
  
  def test_count_ordering
    expected = {"Physics" => 27, "Economics" => 13, "Chemistry" => 12, "Medicine/Physiology" => 9, "Peace" => 2}
    counts = Nobelist.discipline.order('count desc', 'discipline asc').count
    assert_equal expected, counts
    
    expected = {"Chemistry" => 12, "Economics" => 13, "Medicine/Physiology" => 9, "Peace" => 2, "Physics" => 27}
    counts = Nobelist.discipline.order('discipline desc', 'count asc').count
    assert_equal expected, counts
  end

  def test_count_base
    expected = {"Economics" => 5, "Chemistry" => 2, "Physics" => 2, "Medicine/Physiology" => 1}
    counts = Nobelist.discipline.where("name like '%Robert%'").count
    assert_equal expected, counts
  end

  def test_count_minimum
    expected = {"Economics" => 5}
    counts = Nobelist.discipline.where("name like '%Robert%'").minimum(3).count
    assert_equal expected, counts
  end    
  
  def test_count_refinements_1
    expected = {"Chemistry" => 1, "Economics" => 1, "Medicine/Physiology" => 1}
    counts = Nobelist.discipline.refine(:nobel_year => "1987").count
    assert_equal expected, counts
  end
  
  def test_count_refinements_2
    query = {}
    query[:discipline] = [ "Medicine/Physiology" ]
    expected = {1968 => 1, 1969 => 1, 1975 => 1, 1987 => 1, 1990 => 1, 1993 => 1, 2001 => 1, 2002 => 1, 2006 => 1}
    counts = Nobelist.nobel_year.refine(query).count
    assert_equal expected, counts
  end

  def test_count_base_refinements
    query = {}
    query[:discipline] = [ "Medicine/Physiology" ]
    expected = {1993 => 1}
    counts = Nobelist.nobel_year.where(:birth_state => 'Kentucky').refine(query).count
    assert_equal expected, counts
  end

  def test_count_nested_drill
    expected = {"United States of America" => 32, nil => 15, "Germany" => 4, "Canada" => 3, "England" => 2, "British India"=> 1,
                "British Mandate of Palestine" => 1, "Italy" => 1, "Japan" => 1, "Korea" => 1, "Mexico"=> 1,
                "People's Republic of China" => 1}
    counts = Nobelist.birth_place.count
    assert_equal expected, counts

    expected = {"New York" => 7, "California" => 5, "Massachusetts" => 4, "Pennsylvania" => 3, "Illinois" => 2, 
                "Connecticut" => 1, "District of Columbia" => 1, "Florida" => 1, "Indiana" => 1, "Kentucky" => 1, "Michigan"=> 1,
                "Nebraska" => 1, "North Carolina" => 1, "South Carolina" => 1, "Virginia" => 1, "West Virginia" => 1}
    counts = Nobelist.birth_place.refine(:birth_place => [ 'United States of America' ]).count
    assert_equal expected, counts
  
    expected = {"New York City" => 4, "Brooklyn" => 1, "Mineola" => 1, "Queens" => 1}
    counts = Nobelist.birth_place.refine(:birth_place => [ 'United States of America', 'New York' ]).count
    assert_equal expected, counts
    
    expected = []
    counts = Nobelist.birth_place.refine(:birth_place => [ 'United States of America', 'New York', 'New York City' ]).count
    assert_equal expected, counts
  end
  
  def test_count_joined
    expected = {nil => 43, "Ph.D." => 16, "S.B." => 11, "S.M." => 2}
    counts = Nobelist.degree.order('count desc', 'degree asc').count
    assert_equal expected, counts
  end
	
  def test_count_no_nils
	  expected = {nil => 43, "Ph.D." => 16, "S.B." => 11, "S.M." => 2}
	  counts = Nobelist.degree.count
	  assert_equal expected, counts
	  
	  expected = {"Ph.D." => 16, "S.B." => 11, "S.M." => 2}
	  counts = Nobelist.degree.nils(false).count
	  assert_equal expected, counts
  end
end