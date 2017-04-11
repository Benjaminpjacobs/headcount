require_relative 'test_helper'
require_relative '../lib/statewide_test'

class StatewideTestTest < Minitest::Test
  def test_test_exists
    swt = StatewideTest.new
    assert_instance_of StatewideTest, swt
  end
  
end