require_relative 'test_helper.rb'
require_relative '../lib/enrollment_repository.rb'
require_relative '../lib/enrollment'

class EnrollmentRepositoryTest < Minitest::Test
  def test_it_exists
    er = EnrollmentRepository.new
    assert_instance_of EnrollmentRepository, er
  end

  def test_enrollment_can_load_data
    er = EnrollmentRepository.new
    er.load_data({ :enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    actual = er.enrollment.keys.count
    expected = 181
    assert_equal expected, actual
  end

  def test_enrollment_can_load_more_than_one_study
    er = EnrollmentRepository.new
    er.load_data({ :enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv", :high_school_graduation => './data/High school graduation rates.csv', :pupil_enrollment => "./data/Pupil enrollment.csv", :special_education => "./data/Special education.csv"}})
    actual = er.enrollment["COLORADO"].enrollment_statistics[:high_school_graduation]
    expected = {2010=>0.724, 2011=>0.739, 2012=>0.75354, 2013=>0.769, 2014=>0.773}
    assert_equal expected, actual
  end

  def test_find_by_name
    er = EnrollmentRepository.new
    er.load_data({ :enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    actual = er.find_by_name("colorado").name
    expected = 'COLORADO'
    assert_equal expected, actual
    assert_nil er.find_by_name("millburn")
  end

  def test_enrollment_interaction_pattern
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
    :high_school_graduation => "./data/High school graduation rates.csv"}})
    enrollment = er.find_by_name("ACADEMY 20")
    actual = enrollment.graduation_rate_by_year
    expected = {2010=>0.895, 2011=>0.895, 2012=>0.88983, 2013=>0.91373, 2014=>0.898}
    assert_equal expected, actual
    actual = enrollment.graduation_rate_in_year(2011)
    expected = 0.895
    assert_equal expected, actual
  end
  
  def test_chart_all_enrollments
    er = EnrollmentRepository.new
    er.load_data({ :enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv", :high_school_graduation => './data/High school graduation rates.csv', :pupil_enrollment => "./data/Pupil enrollment.csv", :special_education => "./data/Special education.csv"}})
    actual  = er.chart_all_districts.count
    expected = 181
    assert_equal expected, actual
  end
end