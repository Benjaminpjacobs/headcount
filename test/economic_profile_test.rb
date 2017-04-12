require_relative 'test_helper'
require_relative '../lib/economic_profile'
require_relative '../lib/economic_profile_repository'

class EconomicProfileTest < Minitest::Test
  def setup
    @epr = EconomicProfileRepository.new
    @epr.load_data({:economic_profile => {
    :median_household_income => "./data/Median household income.csv",
    :children_in_poverty => "./data/School-aged children in poverty.csv",
    :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
    :title_i => "./data/Title I students.csv"}})
  end

  def test_it_exists
    ec = EconomicProfile.new(:name => "ACADEMY 20", 2010 => 0.783 )
    assert_instance_of EconomicProfile, ec
  end

  def test_median_household_income_in_year
    ec = @epr.profiles["ACADEMY 20"]
    actual = ec.median_household_income_in_year(2012)
    expected = 89784
    assert_equal expected, actual
  end

  def test_median_household_income_average
    ec = @epr.profiles["ACADEMY 20"]
    actual = ec.median_household_income_average
    expected = 87635
    assert_equal expected, actual
  end
end
