require_relative 'test_helper'
require_relative '../lib/district'
require 'pry'
class DistrictTest < Minitest::Test
  def test_it_exists
    d = District.new({:name => "ACADEMY 20"})
    assert_instance_of District, d
  end

  def test_it_can_take_hash_argument
    d = District.new({:name => "ACADEMY 20", :enrollments => "test", :testing => "test2", :economic_profile => "test3"})
    assert_equal "ACADEMY 20", d.name
  end

  def test_delegator
    d = District.new({:name => "ACADEMY 20"})
    d.testing = "test"
    assert_equal "test", d.statewide_test
  end
end