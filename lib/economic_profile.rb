require_relative "custom_errors"
require 'pry'
class EconomicProfile
  attr_accessor :name, :economic_profile

  def initialize(args)
    @name = args[:name]
    @economic_profile = {}
    @economic_profile[args.keys[0]] = args[args.keys[0]] unless args.keys[0] == :name
    @economic_profile[args.keys[1]] = args[args.keys[1]] if args.keys[1]
    @economic_profile[args.keys[2]] = args[args.keys[2]] if args.keys[2]
    @economic_profile[args.keys[3]] = args[args.keys[3]] if args.keys[3]
  end

  def statistics
    @economic_profile
  end

  def median_household_income_in_year(year)
    ranges = @economic_profile[:median_household_income].keys
    ranges = select_included_ranges(ranges, year)
    raise UnknownDataError if ranges.empty?
    ranges = map_incomes_to_ranges(ranges)
    average(ranges)
  end

  def select_included_ranges(ranges, year)
    ranges.select do |range|
      (range[0]..range[1]).include?(year)
    end
  end

  def map_incomes_to_ranges(ranges)
    ranges.map do |range|
      @economic_profile[:median_household_income][range]
    end
  end

  def average(data)
    (data.inject(:+)/data.count).to_i
  end

  def median_household_income_average
    all_ranges = map_incomes_to_ranges(@economic_profile[:median_household_income].keys)
    average(all_ranges)
  end

  def children_in_poverty_in_year(year)
    raise UnknownDataError unless @economic_profile[:children_in_poverty].keys.include?(year)
    @economic_profile[:children_in_poverty][year]
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    raise UnknownDataError unless @economic_profile[:free_or_reduced_price_lunch].keys.include?(year)
    stat = @economic_profile[:free_or_reduced_price_lunch][year][:percent]
    if stat.nil?
      @economic_profile[:free_or_reduced_price_lunch][year][:percentage]
    else
      stat
    end
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    raise UnknownDataError unless @economic_profile[:free_or_reduced_price_lunch].keys.include?(year)
    @economic_profile[:free_or_reduced_price_lunch][year][:total]
  end

  def title_i_in_year(year)
    raise UnknownDataError unless @economic_profile[:title_i].keys.include?(year)
    @economic_profile[:title_i][year]
  end
end
