require './lib/district'
require './lib/enrollment_repository'
require 'csv'
require 'pry'

class DistrictRepository
  attr_accessor :districts, :enrollment_repository

  def initialize
    @districts = {}
    @enrollment_repository = EnrollmentRepository.new
  end

  def add_district(district)
    @districts[district.name] = district
  end

  def load_data(args)
    generate_districts(args)
    @enrollment_repository.load_data(args)
    update_districts
  end

  def update_districts
    @districts.each do |k, v|
      @districts[k].enrollments = @enrollment_repository.enrollments[k]
    end
  end

  def generate_districts(args)
    contents = CSV.open args[:enrollment][:kindergarten], headers: true, header_converters: :symbol
    district_list = map_individual_districts(contents)
    create_district_objects(district_list) 
  end

  def find_by_name(name)
    @districts[name.upcase]if @districts.keys.include?(name.upcase)
  end

  def find_all_matching(name)
    @districts.keys.select do |districts|
      name == districts[0..(name.length - 1)]
    end.map{|key| @districts[key]}
  end

private

  def create_district_objects(district_list)
    district_list.each do |district|
      add_district(District.new(:name => district.upcase))
    end
  end

  def map_individual_districts(contents)
    contents = contents.map do |row|
      row[:location]
    end.uniq!
  end

end
