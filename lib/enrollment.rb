class Enrollment
  attr_reader :name, :enrollment_statistics
  def initialize(args)
    @name = args[:name]
    @enrollment_statistics = {}
    @enrollment_statistics[:kindergarten_participation] = args[:kindergarten_participation]
  end

  def add_new_statistics(args)
    @enrollment_statistics[args.keys[1]] = args[args.keys[1]]
  end
end