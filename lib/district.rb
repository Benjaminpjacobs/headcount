class District
  attr_accessor :name, :repo, :enrollment, :testing, :economic_profile

  def initialize(args)
    @name = args[:name]
    @repo = args[:repo]
  end

  def statewide_test
    @testing
  end

end