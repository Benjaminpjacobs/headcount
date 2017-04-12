require_relative 'test_helper'
require_relative '../lib/statewide_test'
require_relative '../lib/statewide_test_repository'

class StatewideTestTest < Minitest::Test
  def setup
    @str = StatewideTestRepository.new
    @str.load_data({:statewide_testing => {
    :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
    :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
    :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
    :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
    :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"}})
  end

  # def method_name
  #
  # end

  def test_test_exists
    swt = StatewideTest.new(:name => "COLORADO", :third_grade => {2010 => 0.3915})
    assert_instance_of StatewideTest, swt
  end


  def test_proficient_by_grade
    actual = @str.tests["COLORADO"].proficiency_by_grade(3)
    expected = {2008=>{:math=>0.697, :reading=>0.703, :writing=>0.501},
    2009=>{:math=>0.691, :reading=>0.726, :writing=>0.536},
    2010=>{:math=>0.706, :reading=>0.698, :writing=>0.504},
    2011=>{:math=>0.696, :reading=>0.728, :writing=>0.513},
    2012=>{:reading=>0.739, :math=>0.71, :writing=>0.525},
    2013=>{:math=>0.723, :reading=>0.733, :writing=>0.509},
    2014=>{:math=>0.716, :reading=>0.716, :writing=>0.511}}
    assert_equal expected, actual
  end

  
end
