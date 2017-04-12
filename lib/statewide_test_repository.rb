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
      district_tests[row[:location].upcase] << 
      [row[:timeframe].to_i, row[:score].downcase.to_sym, check_if_na(row[:data])]
    else
      district_tests[row[:location].upcase] = 
      [[row[:timeframe].to_i, row[:score].downcase.to_sym, check_if_na(row[:data])]]
    end
  end

  def populate_district_tests_subject(district_tests, row)
    if district_tests.keys.include?(row[:location].upcase)
      district_tests[row[:location].upcase] << 
      [format_race_heading(row[:race_ethnicity]), row[:timeframe].to_i, check_if_na(row[:data])]
    else
      district_tests[row[:location].upcase] = 
      [[format_race_heading(row[:race_ethnicity]), row[:timeframe].to_i, check_if_na(row[:data])]]
    end
  end

  def format_district_tests(district_enrollments)
    district_enrollments.each do |k, v|
      district_enrollments[k] = v.group_by{|v| v.shift}
    end
  end
  
  def format_race_heading(race)
    if race.include?("Hawaiian")
      race = race.scan(/\w+/)
      race.delete("Hawaiian")
      race.join("_").downcase.to_sym
    else
    race.scan(/\w+/).join("_").downcase.to_sym
  end
end

def format_district_tests(district_enrollments)
  district_enrollments.each do |k, v|
    district_enrollments[k] = v.group_by{|v| v.shift}
  end
end

# def load_individual_study(key, value)
#   parse_csv(key, value).each do |district|
#     insert_testing_data(district)
#   end
# end

# def parse_csv(test_heading, test_info)
#   contents = CSV.open test_info, headers: true, header_converters: :symbol
#   divided_districts = divide_districts(contents)
#   formated_districts = format_district_tests(divided_districts)
#   add_study_heading(test_heading, formated_districts)
# end

# def add_test(test_stat)
#   @tests[test_stat.name] = test_stat
# end


# def insert_testing_data(testing_data)
#   if heading_already_exists?(testing_data[1])
#     add_new_test_statistics(testing_data[1], testing_data[0],
#     testing_data[2])
#   else
#     district = create_new_testing_object(testing_data[1], testing_data[0],testing_data[2])
#     add_test(district)
#   end
# end

#   def format_race_heading(race)
#     if race.include?("Hawaiian")
#       race = race.scan(/\w+/)
#       race.delete("Hawaiian")
#       race.join("_").downcase.to_sym
#     else
#     race.scan(/\w+/).join("_").downcase.to_sym
#   end
# end

#   def create_new_testing_object(heading, study, data)
#     StatewideTest.new({:name => heading, study => data})
#   end

#   def heading_already_exists?(heading)
#     @tests.keys.include?(heading)
#   end

#   def add_new_test_statistics(heading, study, data)
#     @tests[heading].tests[study] = data
#   end

#   def add_study_heading(test_heading, district_tests)
#     district_tests.collect do |k, v|
#       [test_heading, k, v]
#     end
#   end


#   def check_if_na(datum)
#     if datum == "N/A"
#       datum
#     else
#       datum.to_f
#     end
#   end
end



