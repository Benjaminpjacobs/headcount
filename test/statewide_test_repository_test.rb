require 'pry'
require_relative 'test_helper'
require_relative '../lib/statewide_test_repository'
require_relative '../lib/statewide_test'


class StatewideTestRepositoryTest < Minitest::Test
  def test_it_exists
    swtr = StatewideTestRepository.new
    assert_instance_of StatewideTestRepository, swtr
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
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {:third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv"}})
    actual = str.find_by_name("colorado").name
    expected = 'COLORADO'
    assert_equal expected, actual
    assert_nil str.find_by_name("millburn")
  end

  def test_chart_all
    str = StatewideTestRepository.new
    str.load_data(:statewide_testing => 
    {
    :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
    :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
    :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
    :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
    :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
      })
    str.chart_all_districts
  end

end
