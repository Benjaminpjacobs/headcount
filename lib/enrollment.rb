require_relative "statistics_module"
require_relative "charts"

class Enrollment
  include Statistics
  attr_accessor :name, :enrollment_statistics

  def initialize(args)
    @name = args[:name]
    @enrollment_statistics = {}
    add_new_statistics(args)
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
    yearly = reject_non_floats(yearly)
    average_and_round(yearly)
  end

  def graduation_rate_by_year
    @enrollment_statistics[find_key_by_tag("high_school")]
  end

  def graduation_rate_in_year(year)
    @enrollment_statistics[find_key_by_tag("high_school")][year].round(3)
  end

  def graduation_rate_average
    yearly = @enrollment_statistics[find_key_by_tag("high_school")].values
    yearly = reject_non_floats(yearly)
    average_and_round(yearly)
  end

  def chart_all_data
    to_chart = prep_chart_data
    to_chart.each do |stat|
      generate_chart(stat[0], stat[1])
    end
  end

  def prep_chart_data
    stats = enrollment_statistics.keys
    stat_labels = stat_labeling
    stats.zip(stat_labels)
  end

  def stat_labeling
    enrollment_statistics.keys.map do |key|
      key.to_s.split("_").join(" ").capitalize
    end
  end
  def generate_chart(which_stat, stat_label)
    name = @name.split("/").join("_")
    chart = Chart.new
    args = set_args(name, stat_label, which_stat)
    chart.make_chart(args)
  end

private

  def set_args(name, stat_label, which_stat)
    {
      directory: "enrollment",
      repo: @enrollment_statistics,
      name: name,
      stat_label: stat_label,
      study_heading: which_stat
    }
  end

  def reject_non_floats(yearly)
    yearly.reject do |value|
      !value.is_a?(Float)
    end
  end

  def find_key_by_tag(tag)
    keys = @enrollment_statistics.keys.map{|key| key.to_s}
    keys.find{ |key| key[0..10] == tag}.to_sym
  end
end