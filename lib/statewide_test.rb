class StatewideTest
  attr_accessor :name, :tests
  def initialize(args)
    @name = args[:name]
    @tests = {}
    @tests[args.keys[1]] = args[args.keys[1]]
  end

  def proficiency_by_grade(grade)
    grade_map = {3 => :third_grade, 8 => :eighth_grade}
    yearly_proficiency = @tests[grade_map[grade]]
    yearly_proficiency.each do |key, value|
      yearly_proficiency[key] = Hash[value.map {|key, value| [key.downcase.to_sym, value.round(3)]}]
    end


  end

end
