require_relative 'test_helper'
require_relative '../lib/statewide_test_repository'
require_relative '../lib/statewide_test'


class StatewideTestRepositoryTest < Minitest::Test
  def test_it_exists
    swtr = StatewideTestRepository.new
    assert_instance_of StatewideTestRepository, swtr
  end

  def test_it_can_create_test_hash
    str = StatewideTestRepository.new
    str.add_test(StatewideTest.new({:name => "ACADEMY 20",
      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv" }))
    assert_instance_of StatewideTest, str.tests["ACADEMY 20"]
    expected = str.tests.keys
    actual = ["ACADEMY 20"]
    assert_equal expected, actual
  end

  def test_can_parse_csv_data
    str = StatewideTestRepository.new
    actual = str.parse_csv(:statewide_testing, "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv")[0][0]
    expected = :statewide_testing
    assert_equal expected, actual
  end

  def test_it_can_create_tests_object
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {:writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"}})
    assert_instance_of StatewideTest, str.tests["COLORADO"]
  end

  def test_it_can_load_data
    str = StatewideTestRepository.new
    str.load_data({
      :statewide_testing => {:writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"}})
    actual = str.tests.keys.count
    expected = 181
    assert_equal expected, actual
  end

  def test_tests_can_load_more_than_one_study
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {:third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
    :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv"}})
    actual = str.tests["COLORADO"].tests.keys
    expected = [:third_grade, :eighth_grade]
    assert_equal expected, actual
  end

  def test_find_by_name
    # skip
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {:third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv"}})
    actual = str.find_by_name("colorado").name
    expected = 'COLORADO'
    assert_equal expected, actual
    assert_nil str.find_by_name("millburn")
  end

end
