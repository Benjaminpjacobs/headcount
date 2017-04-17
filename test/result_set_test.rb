require_relative 'test_helper'
require_relative '../lib/result_set'
require_relative '../lib/district_repository'
require_relative '../lib/headcount_analyst'

class ResultSetTest < Minitest::Test

  def setup
    dr = DistrictRepository.new
    dr.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv",
        :high_school_graduation => "./data/High school graduation rates.csv",
      },
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
        :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
        :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
        :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
      },
      :economic_profile => {
        :median_household_income => "./data/Median household income.csv",
        :children_in_poverty => "./data/School-aged children in poverty.csv",
        :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
        :title_i => "./data/Title I students.csv"
      }
      })
      @hc = HeadcountAnalyst.new(dr)
    end

    def test_it_exists
      rs = ResultSet.new({empty: "hash", test: "hash"})
      assert_instance_of ResultSet, rs
    end

    def test_it_counts_matching_districts
      rs = @hc.high_poverty_and_high_school_graduation
      actual = rs.matching_districts.count
      expected = 5
      assert_equal expected, actual
    end

    def test_it_finds_name_of_district
      rs = @hc.high_poverty_and_high_school_graduation
      actual = rs.matching_districts.first.name
      expected = "DELTA COUNTY 50(J)"
      assert_equal expected, actual
    end
  
    def test_it_can_access_free_lunch
      rs = @hc.high_poverty_and_high_school_graduation
      actual = rs.matching_districts.first.free_and_reduced_price_lunch_rate
      expected = 2296
      assert_equal expected, actual
    end

    def test_it_sees_statewide_average
      rs = @hc.high_poverty_and_high_school_graduation
      assert rs.statewide_average.free_and_reduced_price_lunch_rate
      assert rs.statewide_average.children_in_poverty_rate
      assert rs.statewide_average.high_school_graduation_rate
    end

    def test_income_disparity
      rs = @hc.high_income_disparity
      assert rs.matching_districts.count
      assert rs.matching_districts
      assert rs.matching_districts.first.name
      assert rs.matching_districts.first.median_household_income
      assert rs.matching_districts.first.children_in_poverty_rate
      assert rs.statewide_average
      assert rs.statewide_average.median_household_income
      assert rs.statewide_average.children_in_poverty_rate
    end
  end
