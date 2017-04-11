require './test/test_helper'
require './lib/enrollment'

class EnrollmentTest < Minitest::Test
  def test_it_exists
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_instance_of Enrollment, e
  end

  def test_it_can_parse_hash_into_instance_variables
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_equal "ACADEMY 20", e.name
    expected = {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}
    assert_equal expected, e.enrollment_statistics[:kindergarten]
  end

  def test_it_can_add_more_statistics
   e = Enrollment.new({:name => "ACADEMY 20", :kindergarten => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
   e.add_new_statistics({:name => "ACADEMY 20",:high_school_graduation_rates => { 2010 => 0.895, 2011 => 0.895, 2012 => 0.889,2013 => 0.913, 2014 => 0.898}})
   expected = { 2010 => 0.895, 2011 => 0.895, 2012 => 0.889,2013 => 0.913, 2014 => 0.898}
   actual = e.enrollment_statistics[:high_school_graduation_rates]
   assert_equal expected, actual
   p "#{e.name} => #{e.enrollment_statistics}"
  end

  def test_it_can_find_k_participation_by_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    actual = e.kindergarten_participation_by_year
    expected = {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}
    assert_equal expected, actual
  end

  def test_it_can_find_k_participation_in_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    actual = e.kindergarten_participation_in_year(2011)
    expected = 0.354
    assert_equal expected, actual
  end
  def test_it_can_find_graduation_rate_by_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    e.add_new_statistics({:name => "ACADEMY 20", :high_school_graduation=> {2010 => 0.895, 2011 => 0.895, 2012 => 0.889, 2013 => 0.913, 2014 => 0.898}})
    actual = e.graduation_rate_by_year
    expected = { 2010 => 0.895,2011 => 0.895, 2012 => 0.889, 2013 => 0.913,2014 => 0.898}
    assert_equal expected, actual
  end
  def test_it_can_find_graduation_rate_in_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    e.add_new_statistics({:name => "ACADEMY 20", :high_school_graduation => {2010 => 0.895, 2011 => 0.895, 2012 => 0.889, 2013 => 0.913, 2014 => 0.898}})
    actual = e.graduation_rate_in_year(2010)
    expected = 0.895
    assert_equal expected, actual
  end
end
