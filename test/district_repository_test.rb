require_relative 'test_helper'
require_relative '../lib/district_repository'
require_relative '../lib/district'

class DistrictRepositoryTest < Minitest::Test
  def test_it_exists
    dr = DistrictRepository.new
    assert_instance_of DistrictRepository, dr
  end

  def test_it_can_parse_districts_from_csv
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    expected = 181
    actual = dr.districts.keys.count
    assert_equal expected, actual
  end

  def test_it_can_find_by_name
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    actual = dr.find_by_name("academy 20").name
    expected = 'ACADEMY 20'
    assert_equal expected, actual
    actual = dr.find_by_name("Colorado").name
    expected = 'COLORADO'
    assert_equal expected, actual
    assert_nil dr.find_by_name("Millburn")
  end

  def test_if_can_find_all_matching
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    actual = dr.find_all_matching("AG")
    assert_instance_of District, actual[0]
    assert_instance_of District, actual[1]
  end

  def test_if_can_instance_and_load_enrollment_repo
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    actual = dr.enrollment_repository.enrollment["COLORADO"].enrollment_statistics[:kindergarten]
    expected = {2007=>0.39465, 2006=>0.33677, 
                2005=>0.27807, 2004=>0.24014, 
                2008=>0.5357, 2009=>0.598, 
                2010=>0.64019, 2011=>0.672, 
                2012=>0.695, 2013=>0.70263, 2014=>0.74118}
    assert_equal expected, actual
  end

  def test_it_can_connect_district_object_to_enrollment_info
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    actual = dr.districts["COLORADO"].enrollment.enrollment_statistics[:kindergarten]
    expected = {2007=>0.39465, 2006=>0.33677, 
                2005=>0.27807, 2004=>0.24014, 
                2008=>0.5357, 2009=>0.598, 
                2010=>0.64019, 2011=>0.672, 
                2012=>0.695, 2013=>0.70263, 2014=>0.74118}
    assert_equal expected, actual
  end

  def test_interaction_pattern
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv", :high_school_graduation => "./data/High school graduation rates.csv"}})
    district = dr.find_by_name("ACADEMY 20")
    actual = district.enrollment.kindergarten_participation_in_year(2010)
    expected = 0.436
    assert_equal expected, actual
  end

  def test_it_can_connect_district_object_to_enrollment_info
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"},
                  :statewide_testing => {:third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv"}
                })
    actual = dr.districts["COLORADO"].testing.tests[:third_grade][2011][0]
    expected = [:math, 0.696]
    assert_equal expected, actual
  end
end
