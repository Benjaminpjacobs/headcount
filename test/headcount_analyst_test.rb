require_relative 'test_helper'
require_relative '../lib/headcount_analyst'
require_relative '../lib/district_repository'

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
    end

    # def test_it_exists
    #   hc = HeadcountAnalyst.new(@dr)
    #   assert_instance_of HeadcountAnalyst, hc
    # end
    #
    # def test_can_take_arg_from_direct_repository
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.district_repository
    #   assert_instance_of DistrictRepository, actual
    # end
    #
    # def test_kindergarten_participation_rate_variation_colorado
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
    #   expected = 0.766
    #   assert_equal expected, actual
    # end
    #
    # def test_kindergarten_participation_rate_variation_district
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
    #   expected = 0.447
    #   assert_equal expected, actual
    # end
    #
    # def test_kindergarten_participation_rate_variation_trend
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
    #   expected = {2004=>1.258, 2005=>0.961, 2006=>1.05, 2007=>0.992, 2008=>0.718, 2009=>0.652, 2010=>0.681, 2011=>0.728, 2012=>0.689, 2013=>0.694, 2014=>0.661}
    #   assert_equal expected, actual
    # end
    #
    # def test_high_school_graduation_variation
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.high_school_graduation_variation('ACADEMY 20')
    #   expected = 1.194
    #   assert_equal expected, actual
    # end
    #
    # def test_kindergarten_participation_against_hs_graduation
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.kindergarten_participation_against_high_school_graduation('ACADEMY 20')
    #   expected = 0.642
    #   assert_equal expected, actual
    # end
    #
    # def test_kindergarten_participation_against_hs_graduation
    #   hc = HeadcountAnalyst.new(@dr)
    #   assert hc.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
    # end
    #
    # def test_calculates_statewide_correlation
    #   hc = HeadcountAnalyst.new(@dr)
    #   refute hc.kindergarten_participation_correlates_with_high_school_graduation(:for => "STATEWIDE")
    # end
    #
    # def test_calculates_across_subsets
    #   hc = HeadcountAnalyst.new(@dr)
    #   assert hc.kindergarten_participation_correlates_with_high_school_graduation(
    #   :across => ["ACADEMY 20", "ARICKAREE R-2", 'YUMA SCHOOL DISTRICT 1'])
    # end
    #
    # def test_top_statewide_test_year_over_year_growth
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.top_statewide_test_year_over_year_growth(grade: 3, subject: :math)
    #   expected = ["WILEY RE-13 JT", 0.3]
    #   assert_equal expected, actual
    # end
    # def test_top_three_statewide_test_year_over_year_growth
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math)
    #   expected = [["WILEY RE-13 JT", 0.3], ["SANGRE DE CRISTO RE-22J", 0.072], ["COTOPAXI RE-3", 0.07]]
    #   assert_equal expected, actual
    # end
    #
    # def test_top_three_statewide_test_year_over_year_growth
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.top_statewide_test_year_over_year_growth(grade: 3)
    #   expected = ["SANGRE DE CRISTO RE-22J", 0.071]
    #   assert_equal expected, actual
    # end
    #
    # def test_top_three_statewide_test_year_over_year_growth_weighted
    #   hc = HeadcountAnalyst.new(@dr)
    #   actual = hc.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
    #   expected =  ["OURAY R-1", 0.154]
    #   assert_equal expected, actual
    # end
    #
    # def test_high_poverty_and_high_school_graduation
    #   skip
    #   hc = HeadcountAnalyst.new(@dr)
    #
    # end

    def test_find_statewide_average_free_reduced_lunch
      # skip
      hc = HeadcountAnalyst.new(@dr)
      actual = hc.statewide_average_free_reduced_lunch
      expected = 1584.368
      assert_equal expected, actual
    end

    def test_find_districts_over_avg_free_reduced_lunch
      # skip
      hc = HeadcountAnalyst.new(@dr)
      actual = hc.districts_over_state_avg_free_reduced_lunch.first.name
      expected = "ACADEMY 20"
      assert_equal expected, actual
    end

    def test_find_single_district_avg_percentage_s_a_children_poverty
      hc = HeadcountAnalyst.new(@dr)
      actual = hc.district_avg_school_age_poverty("AGUILAR REORGANIZED 6")
      expected = 0.389
      assert_equal expected, actual
    end

    def test_find_state_avg_school_age_poverty
      hc = HeadcountAnalyst.new(@dr)
      actual = hc.statewide_school_age_poverty
      expected = 0.164
      assert_equal expected, actual

    end
  end
