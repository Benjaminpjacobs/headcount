require_relative 'enrollment'
require_relative 'district'
require_relative 'statewide_test'

class ObjectFactory
 TYPES = {
    district: District,
    enrollment: Enrollment
    statewide_test: StatewideTest
  }

  def self.for(type, attributes)
    TYPES[type].new(attributes)
  end
end
