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
    average(yearly).round(3)
  end

  def graduation_rate_by_year
    @enrollment_statistics[find_key_by_tag("high_school")]
  end

  def graduation_rate_in_year(year)
    @enrollment_statistics[find_key_by_tag("high_school")][year].round(3)
  end

  def graduation_rate_average
    yearly = @enrollment_statistics[find_key_by_tag("high_school")].values
    average(yearly).round(3)
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
