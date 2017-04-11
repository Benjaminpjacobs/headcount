class District
  attr_accessor :name, :enrollments
  
  def initialize(args)
    @name = args[:name]
    @enrollments = args[:enrollments]
  end
  
end