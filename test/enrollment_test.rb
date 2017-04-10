require './test/test_helper'
require './lib/enrollment'

class EnrollmentTest < Minitest::Test
  def test_it_exists
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_instance_of Enrollment, e
  end

  def test_it_can_parse_hash_into_instance_variables
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_equal "ACADEMY 20", e.name
    expected = {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}
    assert_equal expected, e.enrollment_statistics[:kindergarten_participation]
  end

  def test_it_can_add_more_statistics
   e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
   e.add_new_statistics({:name => "ACADEMY 20",:high_school_graduation_rates => { 2010 => 0.895, 2011 => 0.895, 2012 => 0.889,2013 => 0.913, 2014 => 0.898}})
   expected = { 2010 => 0.895, 2011 => 0.895, 2012 => 0.889,2013 => 0.913, 2014 => 0.898}
   actual = e.enrollment_statistics[:high_school_graduation_rates]
   assert_equal expected, actual
   p "#{e.name} => #{e.enrollment_statistics}"
  end

end