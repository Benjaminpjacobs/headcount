require './lib/enrollment'
require 'csv'

class EnrollmentRepository
  attr_reader :enrollments
  def initialize
    @enrollments = {}
  end

  def add_enrollment(enrollment)
    @enrollments[enrollment.name] = enrollment
  end

  def parse_csv(enrollment_heading, enrollment_info)
    contents = CSV.open enrollment_info, headers: true, header_converters: :symbol
    enrollment_data = []
    district_enrollments = divide_districts(contents)
    district_enrollments = format_district_enrollments(district_enrollments)
    district_enrollments.each do |k, v|
      enrollment_data << [enrollment_heading, k, v]
    end
    enrollment_data
  end

  def load_data(arg)
    arg[:enrollment].each do |key, value|
      enrollment_study = parse_csv(key, value)
      enrollment_study.each do |district|
        district = generate_enrollment(district)
        add_enrollment(district)
      end
    end
  end

  def find_by_name(name)
    @enrollments[name.upcase] if @enrollments.keys.include?(name.upcase)
  end

  def generate_enrollment(enrollment_data)
    Enrollment.new({:name => enrollment_data[1], enrollment_data[0] => enrollment_data[2]})
  end

  def divide_districts(contents)
    district_enrollments = {}
    contents = contents.map do |row|
      populate_hash(district_enrollments, row)
    end
    district_enrollments
  end

  def populate_hash(district_enrollments, row)
    if district_enrollments.keys.include?(row[:location].upcase)
      district_enrollments[row[:location].upcase] << [row[:timeframe], row[:data].to_f]
    else
      district_enrollments[row[:location].upcase] = [[row[:timeframe], row[:data].to_f]]
    end
  end

  def format_district_enrollments(district_enrollments)
    district_enrollments.each do |k, v|
      district_enrollments[k] = Hash[*v.flatten(1)]
    end
  end
end