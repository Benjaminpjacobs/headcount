class District
  attr_accessor :name, :enrollments, :testing, :economic_profile
  
  def initialize(args)
    @name = args[:name]
  end
  
end