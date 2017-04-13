require_relative 'economic_profile'
require_relative 'repo_module'

class EconomicProfileRepository
  include Repository
  attr_accessor :profiles

  def initialize
    @profiles = {}
  end

  def load_data(arg)
    arg[:economic_profile].each do |key, value|
      load_individual_study(:economic_profile, @profiles, key, value)
    end
  end

  def find_by_name(name)
    @profiles[name.upcase] if profile_exists?(name)
  end

  def profile_exists?(name)
    @profiles.keys.include?(name.upcase)
  end

  def divide_districts(contents)
    district_profiles = {}
    populate_based_on_study(contents, district_profiles)
  end

  def populate_district_contents(district_profiles, row)
    if district_exists?(district_profiles, row)
      add_profile_data(district_profiles, row)
    else
      create_new_profile(district_profiles, row)
    end
  end

  def populate_district_contents_income(district_profiles, row)
    if district_exists?(district_profiles, row)
      add_income_profile_data(district_profiles, row)
    else
      create_income_profile_data(district_profiles, row)
    end
  end

  def populate_district_contents_lunch(district_profiles, row)
    if district_exists?(district_profiles, row)
      add_lunch_profile_data(district_profiles, row)
    else
      create_lunch_profile_data(district_profiles, row)
    end
  end

  def format_district_profiles(district_profiles)
    if income_data?(district_profiles)
      format_income_data(district_profiles)
    elsif standard_data?(district_profiles)
      format_normal(district_profiles)
    else
      format_free_lunch_data(district_profiles)
    end
  end

  private

  def format_free_lunch_data(data)
    select_eligible_for_free_or_reduced(data)
    sort_by_year(data)
    format_percentages_and_totals(data)
  end

  def format_percentages_and_totals(data)
    data.each{ |key, value| data[key] = format_values(value) }
  end

  def sort_by_year(data)
    data.each do |key, value|
      data[key] = value.group_by { |value| value.shift }
    end
  end
  
  def select_eligible_for_free_or_reduced(data)
    data.each do |key, value|
      data[key] =
      value.select{|value| value[1] == "Eligible for Free or Reduced Lunch"}
    end
  end

  def format_values(data)
    remove_tag(data)
    hash_total_and_percentage(data)
  end

  def hash_total_and_percentage(data)
    data.each do |key, value|
      change_heading_names(value)
      data[key] = value_hash(value)
    end
  end

  def value_hash(value)
    {value[0][0].downcase.to_sym => value[0][1], 
    value[1][0].downcase.to_sym => value[1][1]}
  end

  def change_heading_names(value)
    value[0][0] = "Total" if value[0][0] == "Number"
    value[1][0] = "Total" if value[1][0] == "Number"
    value[0][0] = "Percentage" if value[0][0] == "Percent"
    value[1][0] = "Percentage" if value[1][0] == "Percent"
  end

  def format_normal(district_profiles)
    district_profiles.each do |key, value|
      district_profiles[key] = Hash[*value.flatten]
    end
  end

  def format_income_data(district_profiles)
    district_profiles.each do |key, value|
      district_profiles[key] = hash_value(value)
    end
  end
  
  def hash_value(data)
    hash = {}
    data.each{|value| hash[value[0]] = value[1]}
    hash
  end

  def standard_data?(district_profiles)
    district_profiles[district_profiles.keys[0]][0].count == 2  
  end
  
  def income_data?(district_profiles)
    district_profiles[district_profiles.keys[0]][0][0].is_a?(Array)
  end

  def add_lunch_profile_data(district_profiles, row)
    district_profiles[row[:location].upcase] <<
    [row[:timeframe].to_i, row[:poverty_level],
    row[:dataformat],  row[:data].to_f]
  end

  def create_lunch_profile_data(district_profiles, row)
    district_profiles[row[:location].upcase] =
    [[row[:timeframe].to_i, row[:poverty_level],
    row[:dataformat],  row[:data].to_f]] 
  end

  def add_income_profile_data(district_profiles, row)
    district_profiles[row[:location].upcase] << 
    [format_date_range(row[:timeframe]), row[:data].to_f]
  end

  def create_income_profile_data(district_profiles, row)
    district_profiles[row[:location].upcase] = 
    [[format_date_range(row[:timeframe]), row[:data].to_f]]
  end

  def add_profile_data(district_profiles, row)
    district_profiles[row[:location].upcase] << 
    [row[:timeframe].to_i, row[:data].to_f]
  end
  
  def create_new_profile(district_profiles, row)
    district_profiles[row[:location].upcase] = 
    [[row[:timeframe].to_i, row[:data].to_f]]
  end

  def district_exists?(district_profiles, row)
    district_profiles.keys.include?(row[:location].upcase)
  end

  def remove_tag(data)
    data.each do |key, value|
      data[key] = value.each{|value| value.shift}
    end
  end

  def format_date_range(dates)
    dates.split("-").map!(&:to_i)
  end

  def populate_based_on_study(contents, district_profiles)
    contents.map do |row|
      check_data_for_study_keys(district_profiles, row)
    end
    district_profiles
  end

  def check_data_for_study_keys(district_profiles, row)
    if row[:poverty_level]
      populate_district_contents_lunch(district_profiles, row)
    elsif row[:dataformat].include?("Currency")
      populate_district_contents_income(district_profiles, row)
    else
      populate_district_contents(district_profiles, row)
    end
  end

end
