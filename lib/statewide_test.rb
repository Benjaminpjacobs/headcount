require_relative 'custom_errors'

class StatewideTest
  attr_accessor :name, :tests
  
  VALID_RACES = [:asian, :black, :pacific_islander, :hispanic,
                 :native_american, :two_or_more, :white]
  VALID_SUBJECTS = [:math, :reading, :writing]
  GRADE_MAP = {3 => :third_grade, 8 => :eighth_grade}

  def initialize(args)
    @name = args[:name]
    @tests = {}
    @tests[args.keys[1]] = args[args.keys[1]]
  end

  def statistics
    @tests
  end

  def proficient_by_grade(grade)
    raise UnknownDataError unless GRADE_MAP.keys.include?(grade)
    yearly_proficiency = @tests[GRADE_MAP[grade]]
    compile_proficiencies(yearly_proficiency)
  end

  def proficient_by_race_or_ethnicity(race)
    raise UnknownDataError unless VALID_RACES.include?(race)
    race_stats = compile_subject_stats(race)
    race_stats = group_stats_by_race(race_stats)
    display_proficiencies(race_stats)
  end

  def proficient_for_subject_by_grade_in_year(subject, grade, year)
    raise UnknownDataError unless
    VALID_SUBJECTS.include?(subject) && GRADE_MAP.keys.include?(grade)
    yearly_proficiency = proficient_by_grade(grade)
    raise UnknownDataError unless yearly_proficiency.keys.include?(year)
    yearly_proficiency[year][subject]
  end

  def proficient_for_subject_by_race_in_year(subject, race, year)
    raise UnknownDataError unless
    VALID_SUBJECTS.include?(subject) && VALID_RACES.include?(race)
    race_stat = proficient_by_race_or_ethnicity(race)
    raise UnknownDataError unless race_stat.keys.include?(year)
    race_stat[year][subject]
  end

private

  def add_headings(value)
    values = {}
    add_each_heading(value, v, index, values)
    values
  end

  def add_each_headings(value, v, index, values)
    value.each_with_index do |v, index|
      which_heading(values, v, index)
    end
  end

  def which_heading(values, v, index)
    case index
    when 0
      values[:math] = v[0].round(3)
    when 1
      values[:reading] = v[0].round(3)
    when 2
      values[:writing] = v[0].round(3)
    end
  end

  def compile_proficiencies(yearly_proficiency)
    yearly_proficiency.each do |key, value|
      yearly_proficiency[key] =
      Hash[value.map{ |key, value| [key, round_if_float(value)] }]
    end
  end

  def round_if_float(value)
    value == "N/A" ? value : value.round(3)
  end

  def compile_subject_stats(race)
    @tests[:math][race].zip(@tests[:reading][race]).zip(@tests[:writing][race])
  end
  
  def display_proficiencies(race_stats)
    race_stats.each do |k, v|
      race_stats[k] = add_headings(v)
    end
  end
  
  def group_stats_by_race(race_stats)
    race_stats.flatten.each_slice(2).to_a.group_by{ |sub| sub.shift }
  end

end