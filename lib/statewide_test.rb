class StatewideTest
  attr_accessor :name, :tests
  def initialize(args)
    @name = args[:name]
    @tests = {}
    @tests[args.keys[1]] = args[args.keys[1]]
  end

  def proficient_by_grade(grade)
    raise UnknownDataError unless grade == 3 || grade == 8
    grade_map = {3 => :third_grade, 8 => :eighth_grade}
    yearly_proficiency = @tests[grade_map[grade]]
    yearly_proficiency.each do |key, value|
      yearly_proficiency[key] = Hash[value.map {|key, value| [key, value.round(3)]}]
    end
  end

  def proficient_by_race_or_ethnicity(race)
  valid_races = [:asian, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, :white]
  raise UnknownDataError unless valid_races.include?(race)
  race_states = @tests[:math][race].zip (@tests[:reading][race]).zip(@tests[:writing][race])
  race_stats = race_states.flatten.each_slice(2).to_a.group_by{|sub| sub.shift}
    race_stats.each do |k, v|
      race_stats[k] = add_headings(v)
    end
  end

  def add_headings(value)
    values = {}
    value.each_with_index do |v, index|
      case index
      when 0
      values[:math] = v[0].round(3)
      when 1
      values[:reading] = v[0].round(3)
      when 2
      values[:writing] = v[0].round(3)
      end
    end
    values
  end

end

class UnknownDataError < Exception
end

class UnknownRaceError < Exception
end

