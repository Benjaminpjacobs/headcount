class District
  attr_accessor :name, :enrollment, :testing, :economic_profile

  def initialize(args)
    @name = args[:name]
  end

end