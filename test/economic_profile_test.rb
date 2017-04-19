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

  def test_unknown_data_error_income
    assert_raises(UnknownDataError) do  
      ec = @epr.profiles["ACADEMY 20"]
      ec.median_household_income_in_year(2016)
    end
  end

  def test_children_in_poverty_in_year
    ec = @epr.profiles["BETHUNE R-5"]
    actual = ec.children_in_poverty_in_year(2012)
    expected = 0.237
    assert_equal expected, actual
  end

  def test_unknown_data_error_children
    assert_raises(UnknownDataError) do  
      ec = @epr.profiles["BETHUNE R-5"]
      ec.children_in_poverty_in_year(2016)
    end
  end

  def test_free_or_reduced_price_percentage
    ec = @epr.profiles["BETHUNE R-5"]
    actual = ec.free_or_reduced_price_lunch_percentage_in_year(2010)
    expected = 0.662
    assert_equal expected, actual
  end

  def test_unknown_data_error_lunch
    assert_raises(UnknownDataError) do  
      ec = @epr.profiles["BETHUNE R-5"]
      ec.free_or_reduced_price_lunch_percentage_in_year(2016)
    end
  end
  
  def test_free_or_reduced_price_percentage
    ec = @epr.profiles["BETHUNE R-5"]
    actual = ec.free_or_reduced_price_lunch_number_in_year(2010)
    expected = 86
    assert_equal expected, actual
  end

  def test_unknown_data_error_lunch_number
    assert_raises(UnknownDataError) do  
      ec = @epr.profiles["BETHUNE R-5"]
      ec.free_or_reduced_price_lunch_number_in_year(2016)
    end
  end

  def test_title_i_in_year
    ec = @epr.profiles["PLATTE VALLEY RE-3"]
    actual = ec.title_i_in_year(2009)
    expected = 0.026
    assert_equal expected, actual
  end


  def test_unknown_data_error_lunch_number
    assert_raises(UnknownDataError) do  
      ec = @epr.profiles["BETHUNE R-5"]
      ec.title_i_in_year(2016)
    end
  end

  def test_charts
    ec = @epr.profiles["PLATTE VALLEY RE-3"]
    assert ec.chart_all_data
  end
end
