class ResultSet
  attr_reader :matching_districts, :statewide_average

  def initialize(args)
    @matching_districts = args[:matching_districts]
    @statewide_average = args[:statewide_average]
  end

end
