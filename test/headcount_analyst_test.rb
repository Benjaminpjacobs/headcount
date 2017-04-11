require './test/test_helper'
require './lib/headcount_analyst'
require './lib/district_repository'

class HeadcountAnalystTest < Minitest::Test

    def setup
      @dr = DistrictRepository.new
      @dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
      district = @dr.find_by_name("ACADEMY 20")
    end

    def test_it_exists
      hc = HeadcountAnalyst.new(@dr)
      assert_instance_of HeadcountAnalyst, hc
    end

    def test_can_take_arg_from_direct_repository
      hc = HeadcountAnalyst.new(@dr)
      actual = hc.district_repository
      assert_instance_of DistrictRepository, actual
    end

    def test_kindergarten_participation_rate_variation_colorado
      hc = HeadcountAnalyst.new(@dr)
      actual = hc.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
      expected = 0.766
      assert_equal expected, actual
    end

    def test_kindergarten_participation_rate_variation_district
      hc = HeadcountAnalyst.new(@dr)
      actual = hc.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
      expected = 0.447
      assert_equal expected, actual
    end

    def test_kindergarten_participation_rate_variation_trend
      hc = HeadcountAnalyst.new(@dr)
      actual = hc.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
      expected = {2004=>1.258, 2005=>0.961, 2006=>1.05, 2007=>0.992, 2008=>0.718, 2009=>0.652, 2010=>0.681, 2011=>0.728, 2012=>0.689, 2013=>0.694, 2014=>0.661}
      assert_equal expected, actual
    end

  end
