require_relative 'test_helper'
require_relative '../lib/headcount_analyst'
require_relative '../lib/district_repository'
require_relative '../lib/result_set'

class HeadcountAnalystTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @dr.load_data({
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
      district = @dr.find_by_name("ACADEMY 20")
      @hc = HeadcountAnalyst.new(@dr)
    end

    # def test_it_exists
    #   # binding.pry
    #   assert_instance_of HeadcountAnalyst, @hc
    # end
    
    # def test_can_take_arg_from_direct_repository
    #   actual = @hc.district_repository
    #   assert_instance_of DistrictRepository, actual
    # end
    
    # def test_kindergarten_participation_rate_variation_colorado
    #   actual = @hc.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
    #   expected = 0.766
    #   assert_equal expected, actual
    # end
    
    # def test_kindergarten_participation_rate_variation_district
    #   actual = @hc.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
    #   expected = 0.447
    #   assert_equal expected, actual
    # end
    
    # def test_kindergarten_participation_rate_variation_trend
    #   actual = @hc.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
    #   expected = {2004=>1.258, 2005=>0.961, 2006=>1.05, 2007=>0.992, 2008=>0.718, 2009=>0.652, 2010=>0.681, 2011=>0.728, 2012=>0.689, 2013=>0.694, 2014=>0.661}
    #   assert_equal expected, actual
    # end
    
    # def test_high_school_graduation_variation
    #   actual = @hc.high_school_graduation_variation('ACADEMY 20')
    #   expected = 1.194
    #   assert_equal expected, actual
    # end
    
    # def test_kindergarten_participation_against_hs_graduation
    #   actual = @hc.kindergarten_participation_against_high_school_graduation('ACADEMY 20')
    #   expected = 0.642
    #   assert_equal expected, actual
    # end
    
    # def test_kindergarten_participation_against_hs_graduation
    #   assert @hc.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
    # end
    
    # def test_calculates_statewide_correlation
    #   refute @hc.kindergarten_participation_correlates_with_high_school_graduation(:for => "STATEWIDE")
    # end
    
    # def test_calculates_across_subsets
    #   assert @hc.kindergarten_participation_correlates_with_high_school_graduation(
    #   :across => ["ACADEMY 20", "ARICKAREE R-2", 'YUMA SCHOOL DISTRICT 1'])
    # end

    # def test_top_statewide_test_year_over_year_growth
    #   actual = @hc.top_statewide_test_year_over_year_growth(grade: 3, subject: :math)
    #   expected = ["WILEY RE-13 JT", 0.3]
    #   assert_equal expected, actual
    # end

    # def test_top_three_statewide_test_year_over_year_growth
    #   actual = @hc.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math)
    #   expected = [["WILEY RE-13 JT", 0.3], ["SANGRE DE CRISTO RE-22J", 0.071], ["COTOPAXI RE-3", 0.07]]
    #   assert_equal expected, actual
    # end
    
    # def test_top_three_statewide_test_year_over_year_growth_across_subject
    #   actual = @hc.top_statewide_test_year_over_year_growth(grade: 3)
    #   expected = ["SANGRE DE CRISTO RE-22J", 0.071]
    #   assert_equal expected, actual
    # end
    
    # def test_top_three_statewide_test_year_over_year_growth_weighted
    #   actual = @hc.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
    #   expected =  ["OURAY R-1", 0.154]
    #   assert_equal expected, actual
    # end

    # def test_find_districts_over_avg_free_reduced_lunch
    #   actual = @hc.over_state_average(:lunch).first
    #   expected = ["ACADEMY 20", 1884]
    #   assert_equal expected, actual
    # end

    # def test_find_districts_over_state_avg_school_age_poverty
    #   actual = @hc.over_state_average(:poverty).first
    #   expected = ["ADAMS COUNTY 14", 0.23]
    #   assert_equal expected, actual
    # end

    # def test_find_districts_over_state_avg_hs_grad_rate
    #   actual = @hc.over_state_average(:graduation).first
    #   expected = ["ACADEMY 20",0.898]
    #   assert_equal expected, actual
    # end

    # def test_high_poverty_and_high_school_graduation
    #   actual = @hc.high_poverty_and_high_school_graduation
    #   assert_instance_of ResultSet, actual
    # end

    # def test_high_income_disparity
    #   actual = @hc.high_income_disparity
    #   assert_instance_of ResultSet, actual 
    # end
    
    # def test_kindergarten_participation_against_household_income
    #   actual = @hc.kindergarten_participation_against_household_income("ACADEMY 20")
    #   expected = 0.333
    #   assert_equal expected, actual
    # end

    # def test_kind_part_correlates_with_house_income
    #   refute @hc.kindergarten_participation_correlates_with_household_income(for: "ACADEMY 20")
    #   refute @hc.kindergarten_participation_correlates_with_household_income(for: "LITTLETON 6")
    #   refute @hc.kindergarten_participation_correlates_with_household_income(for: "PUEBLO CITY 60")
    #   assert @hc.kindergarten_participation_correlates_with_household_income(for: "DENVER COUNTY 1")
    # end

    # def test_participation_income_correlation_statewide
    #   refute @hc.kindergarten_participation_correlates_with_household_income(for: "STATEWIDE")
    # end

    def test_part_income_correlation_across_districts
      assert @hc.kindergarten_participation_correlates_with_household_income(:across => ['ACADEMY 20', 'YUMA SCHOOL DISTRICT 1', 'WILEY RE-13 JT', 'SPRINGFIELD RE-4'])
    end

  end
