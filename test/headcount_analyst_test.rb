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

    def test_top_statewide_test_year_over_year_growth
      hc = HeadcountAnalyst.new(@dr)
      actual = hc.top_statewide_test_year_over_year_growth(grade: 3, subject: :math)
      expected = ''
      assert_equal expected, actual
    end


  end
