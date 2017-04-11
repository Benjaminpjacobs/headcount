require './test/test_helper'
require './lib/headcount_analyst'

class HeadcountAnalystTest < Minitest::Test

  def test_it_exists
    hc = HeadcountAnalyst.new
    assert_instance_of HeadcountAnalyst, hc
  end

  




end
