require_relative 'statewide_test'
require_relative 'repo_module'
require 'csv'
require 'pry'

class StatewideTestRepository
  include Repository

  attr_accessor :tests

  def initialize
    @tests = {}
  end

  def load_data(arg)
    arg[:statewide_testing].each do |key, value|
      load_individual_study(:statewide_test, @tests, key, value)
    end
  end

  def find_by_name(name)
    @tests[name.upcase] if test_exists?(name)
  end

  def test_exists?(name)
    @tests.keys.include?(name.upcase)
  end

  def divide_districts(contents)
    district_tests = {}
    contents.each do |row|
      which_populate(district_tests, row)
    end
    district_tests
  end

  def populate_district_tests(district_tests, row)
    if district_exists?(district_tests, row)
      add_test_to_district(district_tests, row)
    else
      create_new_district(district_tests, row)
    end
  end

  def populate_district_tests_subject(district_tests, row)
    if district_exists?(district_tests, row)
      add_subject_results_to_district(district_tests, row)
    else
      create_new_subject_test(district_tests, row)
    end
  end

  def format_district_tests(district_enrollments)
    district_enrollments.each do |district, enrollment|
      district_enrollments[district] = enrollment.group_by{|v| v.shift}
    end
  end

  def chart_all_districts
    @tests.each do |test|
      test[1].chart_all_data
    end
  end

  private

  def format_race_heading(race)
    if race.include?("Hawaiian")
      delete_hawaiian(race)
    else
      add_underscore(race)
    end
  end

  def add_underscore(race)
    race.scan(/\w+/).join("_").downcase.to_sym
  end

  def delete_hawaiian(race)
    race = race.scan(/\w+/)
    race.delete("Hawaiian")
    race.join("_").downcase.to_sym
  end

  def create_new_subject_test(district_tests, row)
    district_tests[row[:location].upcase] =
    [[format_race_heading(row[:race_ethnicity]),
    row[:timeframe].to_i, check_if_na(row[:data])]]
  end
  
  def add_subject_results_to_district(district_tests, row)
    district_tests[row[:location].upcase] <<
    [format_race_heading(row[:race_ethnicity]),
    row[:timeframe].to_i, check_if_na(row[:data])]
  end

  def create_new_district(district_tests, row)
    district_tests[row[:location].upcase] =
    [[row[:timeframe].to_i, row[:score].downcase.to_sym,
    check_if_na(row[:data])]]
  end

  def add_test_to_district(district_tests, row)
    district_tests[row[:location].upcase] <<
    [row[:timeframe].to_i, row[:score].downcase.to_sym,
    check_if_na(row[:data])]
  end

  def district_exists?(district_tests, row)
    district_tests.keys.include?(row[:location].upcase)
  end

  def which_populate(district_tests, row)
    if row[:score]
      populate_district_tests(district_tests, row)
    elsif row[:race_ethnicity]
      populate_district_tests_subject(district_tests, row)
    end
  end

end



