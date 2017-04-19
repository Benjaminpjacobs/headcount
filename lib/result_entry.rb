require_relative 'custom_errors'

class ResultEntry
  attr_reader :results

  def initialize(args)
    @results = args
  end

  def free_and_reduced_price_lunch_rate
    @results[:free_and_reduced_price_lunch_rate] if
    @results[:free_and_reduced_price_lunch_rate]
  end

  def children_in_poverty_rate
    @results[:children_in_poverty_rate] if
    @results[:children_in_poverty_rate]
  end

  def high_school_graduation_rate
    @results[:high_school_graduation_rate] if
    @results[:high_school_graduation_rate]
  end

  def median_household_income
    @results[:median_household_income] if
    @results[:median_household_income]
  end

  def name
    @results[:name]
  end
end
