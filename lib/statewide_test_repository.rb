require_relative 'statewide_test'
require 'csv'
require 'pry'

class StatewideTestRepository
  attr_accessor :tests
  def initialize
    @tests = {}
  end

  def load_data(arg)
    arg[:statewide_testing].each do |key, value|
      load_individual_study(key, value)
    end
  end

  def load_individual_study(key, value)
    parse_csv(key, value).each do |district|
      insert_testing_data(district)
    end
  end
  
  def parse_csv(test_heading, test_info)
    contents = CSV.open test_info, headers: true, header_converters: :symbol
    divided_districts = divide_districts(contents).to_h
    formated_districts = format_district_tests(divided_districts)
    add_study_heading(test_heading, formated_districts)
  end

  def insert_testing_data(testing_data)
    if heading_already_exists?(testing_data[1])
      add_new_test_statistics(testing_data[1], testing_data[0],testing_data[2])
    else
      district = create_new_testing_object(testing_data[1], testing_data[0],testing_data[2])
      add_test(district)
    end
  end

  def add_test(test_stat)
    @tests[test_stat.name] = test_stat
  end
  
  def test_stat_exists?(name)
    @tests.keys.include?(name.upcase)
  end

  def create_new_testing_object(heading, study, data)
    StatewideTest.new({:name => heading, study => data})
  end

  def heading_already_exists?(heading)
    @tests.keys.include?(heading)
  end

  def add_new_test_statistics(heading, study, data)
    @tests[heading].tests[study] = data
  end

  def divide_districts(contents)
    district_tests = {}
    contents.map do |row|
      if row[:score]
        populate_district_tests(district_tests, row)
      elsif row[:race_ethnicity]
        populate_district_tests_subject(district_tests, row)
      end
    end
    district_tests
  end

  def populate_district_tests(district_tests, row)
    if district_tests.keys.include?(row[:location].upcase)
      district_tests[row[:location].upcase] << [row[:score], row[:timeframe].to_i, row[:data].to_f]
    else
      district_tests[row[:location].upcase] = [[row[:score], row[:timeframe].to_i, row[:data].to_f]]
    end
  end

  def populate_district_tests_subject(district_tests, row)
    if district_tests.keys.include?(row[:location].upcase)
      district_tests[row[:location].upcase] << [row[:race_ethnicity], row[:timeframe].to_i, row[:data].to_f]
    else
      district_tests[row[:location].upcase] = [[row[:race_ethnicity], row[:timeframe].to_i, row[:data].to_f]]
    end
  end


  def format_district_tests(district_enrollments)
    district_enrollments.each do |k, v|
      district_enrollments[k] = v.group_by{|v| v.shift}
    end
  end

  def add_study_heading(enrollment_heading, district_enrollments)
    district_enrollments.collect do |k, v|
      [enrollment_heading, k, v]
    end
  end
  
end