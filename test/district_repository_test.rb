require './test/test_helper'
require './lib/district_repository'
require './lib/district'
class DistrictRepositoryTest < Minitest::Test
  def test_it_exists
    dr = DistrictRepository.new
    assert_instance_of DistrictRepository, dr
  end
  
  def test_it_can_create_district_hash
    dr = DistrictRepository.new
    dr.add_district(District.new(:name => "ACADEMY 20"))
    assert_instance_of District, dr.districts["ACADEMY 20"]
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
    expected = ["AGATE 300", "AGUILAR REORGANIZED 6"]
    assert_equal expected, actual
  end
end
