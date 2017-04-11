class StatewideTest
  attr_accessor :name, :tests
  def initialize(args)
    @name = args[:name]
    @tests = {}
    @tests[args.keys[1]] = args[args.keys[1]]
  end
end