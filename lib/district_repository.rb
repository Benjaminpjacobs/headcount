require './lib/district'
require 'csv'
require 'pry'

class DistrictRepository
  attr_reader :districts

  def initialize
    @districts = {}
  end

  def add_district(district)
    @districts[district.name] = district
  end

  def load_data(args)
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
