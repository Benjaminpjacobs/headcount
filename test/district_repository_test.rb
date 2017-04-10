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

  def method_name
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    expected = ''
    actual = dr.keys.count
  end
end
