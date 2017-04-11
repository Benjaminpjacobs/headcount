require_relative 'enrollment'
require 'forwardable'
require 'csv'

class EnrollmentRepository
  attr_accessor :enrollment

  def initialize
    @enrollment = {}
  end

  def add_enrollment(enrollment)
    @enrollment[enrollment.name] = enrollment
  end

  def parse_csv(enrollment_heading, enrollment_info)
    contents = CSV.open enrollment_info, headers: true, header_converters: :symbol
    district_enrollments = divide_districts(contents)
    district_enrollments = format_district_enrollments(district_enrollments)
    add_study_heading(enrollment_heading, district_enrollments)
  end


  def load_data(arg)
    arg[:enrollment].each do |key, value|
      enrollment_study = parse_csv(key, value)
      enrollment_study.each do |district|
        insert_enrollment_data(district)
      end
    end
  end

  def find_by_name(name)
    @enrollment[name.upcase] if @enrollment.keys.include?(name.upcase)
  end


  def insert_enrollment_data(enrollment_data)
    if @enrollment.keys.include?(enrollment_data[1])
      @enrollment[enrollment_data[1]].enrollment_statistics[enrollment_data[0]] = enrollment_data[2]
    else
      district = Enrollment.new({:name => enrollment_data[1], enrollment_data[0] => enrollment_data[2]})
      add_enrollment(district)
    end
  end

  private

  def add_study_heading(enrollment_heading, district_enrollments)
    enrollment_data = []
    district_enrollments.each do |k, v|
      enrollment_data << [enrollment_heading, k, v]
    end
    enrollment_data
  end

  def divide_districts(contents)
    district_enrollments = {}
    contents = contents.map do |row|
      populate_district_enrollments(district_enrollments, row)
    end
    district_enrollments
  end

  def populate_district_enrollments(district_enrollments, row)
    if district_enrollments.keys.include?(row[:location].upcase)
      district_enrollments[row[:location].upcase] << [row[:timeframe].to_i, row[:data].to_f]
    else
      district_enrollments[row[:location].upcase] = [[row[:timeframe].to_i, row[:data].to_f]]
    end
  end

  def format_district_enrollments(district_enrollments)
    district_enrollments.each do |k, v|
      district_enrollments[k] = Hash[*v.flatten(1)]
    end
  end
end
