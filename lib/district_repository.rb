require_relative 'district'
require_relative 'enrollment_repository'
require_relative 'statewide_test_repository'
require_relative 'economic_profile_repository'
require 'csv'

class DistrictRepository
  attr_accessor :districts, :enrollment_repository, :economic_profile_repository

  def initialize
    @districts = {}
    @enrollment_repository = EnrollmentRepository.new
    @statewide_test_repository = StatewideTestRepository.new
    @economic_profile_repository = EconomicProfileRepository.new
  end

  def load_data(args)
    generate_districts(args)
    load_enrollment_repo(args)
    load_testing_repo(args)
    load_economics_repo(args)
    update_districts
  end

  def find_by_name(name)
    @districts[name.upcase]if district_exists?(name)
  end

  def find_all_matching(name)
    collect_matching_keys(name).map do |key|
      @districts[key]
    end
  end

private

  def load_enrollment_repo(args)
    @enrollment_repository.load_data(args) if args.keys.include?(:enrollment)
  end

  def load_testing_repo(args)
    @statewide_test_repository.load_data(args) if args.keys.include?(:statewide_testing)
  end

  def load_economics_repo(args)
    @economic_profile_repository.load_data(args) if args.keys.include?(:economic_profile)
  end

  def collect_matching_keys(name)
    @districts.keys.select do |districts|
      name == districts[0..(name.length - 1)]
    end
  end

  def district_exists?(name)
    @districts.keys.include?(name.upcase)
  end

  def add_district(district)
    @districts[district.name] = district
  end

  def update_districts
    @districts.keys.each do |k|
      update_each_repository(k)
    end
  end

  def update_each_repository(k)
    @districts[k].enrollment = @enrollment_repository.enrollment[k]
    @districts[k].testing = @statewide_test_repository.tests[k]
    @districts[k].economic_profile = @economic_profile_repository.profiles[k]
  end

  def generate_districts(args)
    contents = CSV.open args[args.keys[0]].values[0],
    headers: true, header_converters: :symbol
    district_list = map_individual_districts(contents)
    create_district_objects(district_list)
  end

  def create_district_objects(district_list)
    district_list.each do |district|
      add_district(District.new({:name => district.upcase, :repo => self}))
    end
  end

  def map_individual_districts(contents)
    contents.map do |row|
      row[:location]
    end.uniq!
  end
end
