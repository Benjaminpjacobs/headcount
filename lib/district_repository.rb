require './lib/district'

class DistrictRepository
  attr_reader :districts
  
  def initialize
    @districts = {}
  end

  def add_district(district)
    @districts[district.name] = district
  end
end