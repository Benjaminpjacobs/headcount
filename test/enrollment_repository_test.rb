require './test/test_helper.rb'
require './lib/enrollment_repository.rb'
require './lib/enrollment'

class EnrollmentRepositoryTest < Minitest::Test

  def test_it_exists
    er = EnrollmentRepository.new
    assert_instance_of EnrollmentRepository, er
  end

  def test_it_can_create_repository_hash
    er = EnrollmentRepository.new
    er.add_enrollment(Enrollment.new({:name => "ACADEMY 20",
      :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}}))
    assert_instance_of Enrollment, er.enrollments["ACADEMY 20"]
    expected = er.enrollments.keys
    actual = ["ACADEMY 20"]
    assert_equal expected, actual
  end

  def test_can_parse_csv_data
    er = EnrollmentRepository.new
    actual = er.parse_csv(:kindergarten_participation, "./data/Kindergartners in full-day program.csv")[0]
    expected = [:kindergarten_participation, "COLORADO", {"2007"=>0.39465, "2006"=>0.33677, "2005"=>0.27807,
                                                          "2004"=>0.24014, "2008"=>0.5357, "2009"=>0.598,
                                                          "2010"=>0.64019, "2011"=>0.672, "2012"=>0.695,
                                                          "2013"=>0.70263, "2014"=>0.74118}]
    assert_equal expected, actual
  end

  def test_it_can_create_enrollment_object
    er = EnrollmentRepository.new
    data = er.parse_csv(:kindergarten_participation, "./data/Kindergartners in full-day program.csv")
    actual = er.generate_enrollment(data[0]).name
    expected ="COLORADO"
    assert_equal expected, actual
  end

  def test_enrollment_can_load_data
    er = EnrollmentRepository.new
    er.load_data({ :enrollment => {:kindergarten_participation => "./data/Kindergartners in full-day program.csv"}})
    actual = er.enrollments.keys.count
    expected = 181
    assert_equal expected, actual
  end

  def test_find_by_name
    er = EnrollmentRepository.new
    er.load_data({ :enrollment => {:kindergarten_participation => "./data/Kindergartners in full-day program.csv"}})
    actual = er.find_by_name("colorado").name
    expected = 'COLORADO'
    assert_equal expected, actual
    assert_nil er.find_by_name("millburn")
  end
end