require_relative 'test_helper'
require_relative '../lib/economic_profile_repository'

class EconomicProfileRepositoryTest < Minitest::Test

  def test_it_exists
    ec = EconomicProfileRepository.new
    assert_instance_of EconomicProfileRepository, ec
  end
  
  def test_economic_profile_can_load_data
    ec = EconomicProfileRepository.new
    ec.load_data({:economic_profile => {
    :median_household_income => "./data/Median household income.csv"}})
    actual = ec.profiles.keys.count
    expected = 181
    assert_equal expected, actual
  end

  def test_economic_profile_can_load_similarly_typed_csv_data
    ec = EconomicProfileRepository.new
    ec.load_data({:economic_profile => {
    :median_household_income => "./data/Median household income.csv",
    :children_in_poverty => "./data/School-aged children in poverty.csv",
    :title_i => "./data/Title I students.csv"}})
    actual = ec.profiles["ACADEMY 20"].economic_profile.keys.count
    expected = 3
    assert_equal expected, actual
  end

  def test_it_can_sort_dissimilarly_typed_csv_data
    ec = EconomicProfileRepository.new
    ec.load_data({:economic_profile => {
    :median_household_income => "./data/Median household income.csv",
    :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv"}})
    actual = ec.profiles["ASPEN 1"].economic_profile[:free_or_reduced_price_lunch][2014]
    expected = {:total=>89.0, :percent=>0.05068}
    assert_equal expected, actual
  end

  def test_with_all_csv_data
    ec = EconomicProfileRepository.new
    ec.load_data({:economic_profile => {
    :median_household_income => "./data/Median household income.csv",
    :children_in_poverty => "./data/School-aged children in poverty.csv",
    :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
    :title_i => "./data/Title I students.csv"}})
    actual = ec.profiles["BENNETT 29J"].economic_profile.keys
    expected = [:median_household_income, :children_in_poverty, :free_or_reduced_price_lunch, :title_i]
    assert_equal expected, actual
  end
end
