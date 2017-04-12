class EconomicProfile
  attr_accessor :name, :economic_profile

  def initialize(args)
    @name = args[:name]
    @economic_profile = {}
    @economic_profile[args.keys[1]] = args[args.keys[1]]
  end

  def statistics
    @economic_profile
  end

  def median_household_income_in_year(year)
    ranges = @economic_profile[:median_household_income].keys
    ranges = select_included_ranges(ranges, year)
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
end
