require 'pry'
require_relative "charts"

class Enrollment
  attr_accessor :name, :enrollment_statistics

  def initialize(args)
    @name = args[:name]
    @enrollment_statistics = {}
    @enrollment_statistics[args.keys[1]] = args[args.keys[1]]
  end

  def statistics
    @enrollment_statistics
  end

  def add_new_statistics(args)
    @enrollment_statistics[args.keys[1]] = args[args.keys[1]]
  end

  def kindergarten_participation_by_year
    @enrollment_statistics[find_key_by_tag("kindergarte")]
  end

  def kindergarten_participation_in_year(year)
    @enrollment_statistics[find_key_by_tag("kindergarte")][year].round(3)
  end

  def kindergarten_participation_average
    yearly = @enrollment_statistics[find_key_by_tag("kindergarte")].values
     yearly = yearly.reject do |value|
      !value.is_a?(Float)
    end
    if yearly.empty?
      0.0
    else
      average(yearly).round(3)
    end
  end

  def graduation_rate_by_year
    @enrollment_statistics[find_key_by_tag("high_school")]
  end

  def graduation_rate_in_year(year)
    @enrollment_statistics[find_key_by_tag("high_school")][year].round(3)
  end

  def graduation_rate_average
    yearly = @enrollment_statistics[find_key_by_tag("high_school")].values
    yearly = yearly.reject do |value|
      !value.is_a?(Float)
    end
    if yearly.empty?
      nil
    else
      average(yearly).round(3)
    end
  end

  def chart_all_data
    stats = enrollment_statistics.keys
    stat_labels = enrollment_statistics.keys.map{|key| key.to_s.split("_").join(" ").capitalize}
    to_chart = stats.zip(stat_labels)
    to_chart.each do |stat|
      generate_chart(stat[0], stat[1])
    end 
  end
  
  def generate_chart(stat, stat_label)
    chart = Chart.new
    chart.enrollment(@name, @enrollment_statistics, stat, stat_label)
  end

private

  def find_key_by_tag(tag)
    keys = @enrollment_statistics.keys.map{|key| key.to_s}
    keys.find{ |key| key[0..10] == tag}.to_sym
  end

  def average(data)
    (data.inject(:+)/data.count)
  end
end
