class District
  attr_accessor :name, :enrollment, :testing, :economic_profile

  def initialize(args)
    @name = args[:name]
    @testing = ''
  end

  def statewide_test
    @testing
  end

end