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

  def test_test_exists
    swt = StatewideTest.new(:name => "COLORADO", :third_grade => {2010 => 0.3915})
    assert_instance_of StatewideTest, swt
  end

  def test_unknown_data_error
    assert_raises(UnknownDataError) do  
      @str.tests["COLORADO"].proficient_by_grade(6)
    end
  end
  
  def test_proficient_by_grade
    actual = @str.tests["COLORADO"].proficient_by_grade(3)
    expected = {2008=>{:math=>0.697, :reading=>0.703, :writing=>0.501},
    2009=>{:math=>0.691, :reading=>0.726, :writing=>0.536},
    2010=>{:math=>0.706, :reading=>0.698, :writing=>0.504},
    2011=>{:math=>0.696, :reading=>0.728, :writing=>0.513},
    2012=>{:reading=>0.739, :math=>0.71, :writing=>0.525},
    2013=>{:math=>0.723, :reading=>0.733, :writing=>0.509},
    2014=>{:math=>0.716, :reading=>0.716, :writing=>0.511}}
    assert_equal expected, actual
  end

  def test_proficient_by_race
    actual = @str.tests["ACADEMY 20"].proficient_by_race_or_ethnicity(:asian)
    expected = { 2011 => {math: 0.817, reading: 0.898, writing: 0.827},
     2012 => {math: 0.818, reading: 0.893, writing: 0.808},
     2013 => {math: 0.805, reading: 0.902, writing: 0.811},
     2014 => {math: 0.800, reading: 0.855, writing: 0.789},
   }
      assert_equal expected, actual
  end
  
  def test_proficient_for_subject_by_grade_in_year
    actual = @str.tests["ACADEMY 20"].proficient_for_subject_by_grade_in_year(:math, 3, 2008)
    expected = 0.857
    assert_equal expected, actual
  end

  def test_proficient_by_race_in_year_subject
    actual = @str.tests["ACADEMY 20"].proficient_for_subject_by_race_in_year(:math, :asian, 2012)
    expected = 0.818
    assert_equal expected, actual
  end

  def test_n_a_handling
    actual = @str.tests["AGATE 300"].proficient_for_subject_by_grade_in_year(:math, 3, 2010)
    expected = 'N/A'
    assert_equal expected, actual
  end

  def test_avg_prof_by_grade
    actual = @str.tests["ACADEMY 20"].average_proficiency_by_grade(3)
    expected = {:math=>0.838, :reading=>0.86, :writing=>0.669}
    assert_equal expected, actual
  end

  def test_year_over_year_growth_grade_subject
    district = @str.tests["ACADEMY 20"]
    actual = district.year_over_year_growth_per_subject(grade: 3, subject: :reading)
    expected = -0.005831666666666661
    assert_equal expected, actual
  end

  def test_year_over_year_growth_across_subjects
    district = @str.tests["OURAY R-1"]
    actual = district.year_over_year_growth_across_subject(grade: 8)
    expected = 0.11016666666666668
    assert_equal expected, actual
  end

  def test_year_over_year_growth_across_subjects
    district = @str.tests["OURAY R-1"]
    actual = district.year_over_year_growth_across_subject(grade: 8)
    expected = 0.11016666666666668
    assert_equal expected, actual
  end

  def test_year_over_year_growth_across_subjects_weighted
    district = @str.tests["OURAY R-1"]
    actual = district.year_over_year_growth_across_subject(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
    expected = 0.1535
    assert_equal expected, actual
  end

  def test_year_over_year_growth_across_subjects_weighted_error
    district = @str.tests["OURAY R-1"]
    assert_raises(WeightingError) do  
      district.year_over_year_growth_across_subject(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.2})
    end
  end

  def test_chart
    district = @str.tests["ACADEMY 20"]
    district.chart_all_data
  end
end
