class Enrollment
  attr_accessor :name, :enrollment_statistics
  def initialize(args)
    @name = args[:name]
    @enrollment_statistics = {}
    @enrollment_statistics[:kindergarten] = args[:kindergarten]
  end

  def add_new_statistics(args)
    @enrollment_statistics[args.keys[1]] = args[args.keys[1]]
  end

  def kindergarten_participation_by_year
    @enrollment_statistics[:kindergarten]
  end

  def kindergarten_participation_in_year(year)
    @enrollment_statistics[:kindergarten][year].round(3)
  end

  def graduation_rate_by_year
    @enrollment_statistics[:high_school_graduation]
  end

  def graduation_rate_in_year(year)
    @enrollment_statistics[:high_school_graduation][year].round(3)
  end
end
