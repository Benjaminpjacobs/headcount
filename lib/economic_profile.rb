require_relative "custom_errors"
require_relative "statistics_module"

class EconomicProfile
  include Statistics
  attr_accessor :name, :economic_profile

  def initialize(args)
    @name = args[:name]
    @economic_profile = {}
    profile_assignments(args)
  end

  def statistics
    @economic_profile
  end

  def median_household_income_in_year(year)
    selected_ranges = select_included_ranges(median_ranges, year)
    raise UnknownDataError if selected_ranges.empty?
    incomes = map_incomes_to_ranges(selected_ranges)
    average(incomes)
  end

  def median_household_income_average
    all_ranges = map_incomes_to_ranges(median_ranges)
    average(all_ranges).to_i
  end

  def children_in_poverty_in_year(year)
    raise UnknownDataError unless
    data_known?(:children_in_poverty, year)
    @economic_profile[:children_in_poverty][year]
  end

  def children_in_poverty_average
    yearly = @economic_profile[:children_in_poverty].values
    average_and_round(yearly)
    # average(yearly).round(3)
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    raise UnknownDataError unless
    data_known?(:free_or_reduced_price_lunch, year)
    @economic_profile[:free_or_reduced_price_lunch][year][:percentage]
  end

  def free_or_reduced_price_lunch_percentage_average
    yearly = @economic_profile[:free_or_reduced_price_lunch].values.map do |v|
      v[:percentage] unless v[:percentage].nil?
    end.compact
    average_and_round(yearly)
    # average(yearly).round(3)
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    raise UnknownDataError unless
    data_known?(:free_or_reduced_price_lunch, year)
    @economic_profile[:free_or_reduced_price_lunch][year][:total]
  end

  def free_or_reduced_price_lunch_number_average
    yearly = @economic_profile[:free_or_reduced_price_lunch].values.map do |v|
      v[:total] unless v[:total].nil?
    end.compact
    average(yearly).to_i
  end

  def title_i_in_year(year)
    raise UnknownDataError unless
    data_known?(:title_i, year)
    @economic_profile[:title_i][year]
  end

  def title_i_average
    yearly = @economic_profile[:title_i].each_value
    average_and_round(yearly)
    # average(yearly).round(3)
  end

  private

  def median_ranges
    @economic_profile[:median_household_income].keys
  end

  def data_known?(symbol, year)
    @economic_profile[symbol].keys.include?(year)
  end

  def profile_assignments(args)
    @economic_profile[args.keys[0]] = args[args.keys[0]] unless
    args.keys[0] == :name
    @economic_profile[args.keys[1]] = args[args.keys[1]] if
    args.keys[1]
    @economic_profile[args.keys[2]] = args[args.keys[2]] if
    args.keys[2]
    @economic_profile[args.keys[3]] = args[args.keys[3]] if
    args.keys[3]
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
end