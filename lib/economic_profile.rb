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

  
end
