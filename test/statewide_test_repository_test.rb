require_relative 'test_helper'
require_relative '../lib/statewide_test_repository'
require_relative '../lib/statewide_test'


class StatewideTestRepositoryTest < Minitest::Test
  def test_it_exists
    swtr = StatewideTestRepository.new
    assert_instance_of StatewideTestRepository, swtr
  end

  def test_it_can_load_data
    str = StatewideTestRepository.new
    str.load_data({
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
        :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
        :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
        :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
      }
    })
    actual = str.tests.values
    expected = ''
    assert_equal expected, actual
  end
end
