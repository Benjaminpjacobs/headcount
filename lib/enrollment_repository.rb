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

  def divide_districts(contents)
    district_enrollments = {}
    contents.each do |row|
      add_or_create_district(district_enrollments, row)
    end
    district_enrollments
  end


  def format_district_enrollments(district_enrollments)
    district_enrollments.each do |k, v|
      district_enrollments[k] = Hash[*v.flatten(1)]
    end
  end

  def chart_all_districts
    @enrollments.each do |enrollment|
      enrollment[1].chart_all_data
    end
  end

  private

  def add_or_create_district(district_enrollments, row)
    if district_exists?(district_enrollments, row)
      add_data_to_district(district_enrollments, row)
    else
      create_new_district_item(district_enrollments, row)
    end
  end

  def create_new_district_item(district_contents, row)
    district_contents[row[:location].upcase] =
    [[row[:timeframe].to_i, check_if_na(row[:data])]]
  end

  def add_data_to_district(district_contents, row)
    district_contents[row[:location].upcase] <<
    [row[:timeframe].to_i, check_if_na(row[:data])]
  end

  def district_exists?(district_contents, row)
    district_contents.keys.include?(row[:location].upcase)
  end

  def enrollment_exists?(name)
    @enrollments.keys.include?(name.upcase)
  end
end
