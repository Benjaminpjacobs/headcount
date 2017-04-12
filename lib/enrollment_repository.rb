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
      district_contents[row[:location].upcase] << [row[:timeframe].to_i, row[:data].to_f]
    else
      district_contents[row[:location].upcase] = [[row[:timeframe].to_i, row[:data].to_f]]
    end
  end


  # def load_individual_study(key, value)
  #   parse_csv(key, value).each do |district|
  #     insert_enrollment_data(district)
  #   end
  # end

  # def parse_csv(enrollment_heading, enrollment_info)
  #   contents = CSV.open enrollment_info, headers: true, header_converters: :symbol
  #   divided_districts = divide_districts(contents)
  #   formated_districts = format_district_enrollments(divided_districts)
  #   add_study_heading(enrollment_heading, formated_districts)
  # end

  # def add_enrollment(enrollment)
  #   @enrollments[enrollment.name] = enrollment
  # end

  # def insert_enrollment_data(enrollment_data)
  #   if heading_already_exists?(enrollment_data[1])
  #     add_new_enrollment_statistics(enrollment_data[1], enrollment_data[0],enrollment_data[2])
  #   else
  #     district = create_new_enrollment_object(enrollment_data[1], enrollment_data[0],enrollment_data[2])
  #     add_enrollment(district)
  #   end
  # end
  

  # private

  # def create_new_enrollment_object(heading, study, data)
  #   Enrollment.new({:name => heading, study => data})
  # end

  # def heading_already_exists?(heading)
  #   @enrollments.keys.include?(heading)
  # end

  # def add_new_enrollment_statistics(heading, study, data)
  #   @enrollments[heading].enrollment_statistics[study] = data
  # end

  # def add_study_heading(enrollment_heading, district_enrollments)
  #   district_enrollments.collect do |k, v|
  #     [enrollment_heading, k, v]
  #   end
  # end

  # def populate_district_enrollments(district_enrollments, row)
  #   if district_enrollments.keys.include?(row[:location].upcase)
  #     district_enrollments[row[:location].upcase] << [row[:timeframe].to_i, row[:data].to_f]
  #   else
  #     district_enrollments[row[:location].upcase] = [[row[:timeframe].to_i, row[:data].to_f]]
  #   end
  # end
end
