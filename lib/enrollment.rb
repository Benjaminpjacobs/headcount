require 'pry'
class Enrollment
  attr_accessor :name, :enrollment_statistics
  def initialize(args)
    @name = args[:name]
    @enrollment_statistics = {}
    @enrollment_statistics[args.keys[1]] = args[args.keys[1]]
  end

  def add_new_statistics(args)
    @enrollment_statistics[args.keys[1]] = args[args.keys[1]]
  end

  def kindergarten_participation_by_year
    @enrollment_statistics[find_kinder_key.to_sym]
  end

  def kindergarten_participation_in_year(year)
    @enrollment_statistics[find_kinder_key.to_sym][year].round(3)
  end

  def graduation_rate_by_year
    @enrollment_statistics[:high_school_graduation]
  end

  def graduation_rate_in_year(year)
    @enrollment_statistics[:high_school_graduation][year].round(3)
  end

private

  def find_kinder_key
    keys = @enrollment_statistics.keys.map{|key| key.to_s}
    keys.find{ |key| key[0..11] == "kindergarten" }
  end

end
