require_relative 'enrollment'
require_relative 'repo_module'
require 'csv'

class EnrollmentRepository
  include Repository

  attr_accessor :enrollment

  def initialize
    @enrollments = {}
  end

  def load_data(arg)
    arg[:enrollment].each do |key, value|
      load_individual_study(:enrollment, @enrollments, key, value)
    end
  end

  def find_by_name(name)
    @enrollments[name.upcase] if enrollment_exists?(name)
  end

  def enrollment
    @enrollments
  end

  def enrollment_exists?(name)
    @enrollments.keys.include?(name.upcase)
  end

  def divide_districts(contents)
    district_enrollments = {}
    contents.map do |row|
      populate_district_contents(district_enrollments, row)
    end
    district_enrollments
  end

  def format_district_enrollments(district_enrollments)
    district_enrollments.each do |k, v|
      district_enrollments[k] = Hash[*v.flatten(1)]
    end
  end

  def populate_district_contents(district_contents, row)
    if district_contents.keys.include?(row[:location].upcase)
      district_contents[row[:location].upcase] <<
      [row[:timeframe].to_i, check_if_na(row[:data])]
    else
      district_contents[row[:location].upcase] =
      [[row[:timeframe].to_i, check_if_na(row[:data])]]
    end
  end

end
