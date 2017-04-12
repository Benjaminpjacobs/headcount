require 'pry'
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
    @enrollment_statistics[find_kinder_key.to_sym]
  end

  def kindergarten_participation_in_year(year)
    @enrollment_statistics[find_kinder_key.to_sym][year].round(3)
  end

  def graduation_rate_by_year
    @enrollment_statistics[find_hs_key.to_sym]
  end

  def graduation_rate_in_year(year)
    @enrollment_statistics[find_hs_key.to_sym][year].round(3)
  end

private

  def find_hs_key
    keys = @enrollment_statistics.keys.map{|key| key.to_s}
    keys.find{ |key| key[0..10] == "high_school" }
  end

  def find_kinder_key
    keys = @enrollment_statistics.keys.map{|key| key.to_s}
    keys.find{ |key| key[0..11] == "kindergarten" }
  end

end
