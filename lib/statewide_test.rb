require_relative 'custom_errors'
require_relative "statistics_module"

class StatewideTest
  include Statistics
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

  def average_proficiency_by_grade(grade)
    math, reading, writing = [], [], []
    heading = [math, reading, writing]
    map_subject_for_average(grade, heading)
    check_for_na(heading)
    hash_results(heading)
  end

  def year_over_year_growth_across_subject(args)
    raise InsufficientInformationError unless
    GRADE_MAP.keys.include?(args[:grade])
    stats = retrieve_yearly_growth_per_subject(args)
    if args[:weighting]
      weights = map_weights(args)
      weighted_yearly_growth(stats, weights)
    else
      stats.inject(:+)/3
    end
  end

  def year_over_year_growth_per_subject(args)
    raise InsufficientInformationError unless
    GRADE_MAP.keys.include?(args[:grade])
    subject_stats = organize_subject_stats(args)
    years = collect_years(args)
    stats = collect_subject_statistics(subject_stats, args)
    year_subject_stats = find_usable_yearly_statistics(years, stats)
    yearly_growth(year_subject_stats)
  end


  def chart_all_data
    grade = to_chart[0..1]
    subjects = to_chart[2..4]
    chart(grade)
    chart(subjects)
  end

  def to_chart
    stats = @tests.keys
    stat_labels = stat_labeling
    stats.zip(stat_labels)
  end

  def stat_labeling
    @tests.keys.map do |key|
      key.to_s.split("_").join(" ").capitalize
    end
  end

  def chart(heading)
    heading.each do |grade|
      generate_chart(grade[0], grade[1])
    end
  end

  def generate_chart(which_stat, stat_label)
    name = @name.split("/").join("_")
    chart = Chart.new
    args = set_args(name, stat_label, which_stat)
    chart.make_chart(args)
  end

  private

  def set_args(name, stat_label, which_stat)
    {
      directory: "statewide_test",
      repo: @tests,
      name: name,
      stat_label: stat_label,
      study_heading: which_stat
    }
  end

  def weighted_yearly_growth(stats, weights)
    stats.zip(weights).map{|statweight| statweight.inject(:*)}.inject(:+)
  end

  def map_weights(args)
    raise WeightingError, "weights must add up to 1.0" unless
    args[:weighting].values.inject(:+) == 1.0
    [args[:weighting][:math],
     args[:weighting][:reading],
     args[:weighting][:writing]]
  end

  def retrieve_yearly_growth_per_subject(args)
    m = year_over_year_growth_per_subject(
      {grade: args[:grade], subject: :math})
    r = year_over_year_growth_per_subject(
      {grade: args[:grade], subject: :reading})
    w = year_over_year_growth_per_subject(
      {grade: args[:grade], subject: :writing})
    [m, r, w]
  end

  def yearly_growth(year_subject_stats)
    if year_subject_stats.count <= 1
      0.0
    else
      (year_subject_stats.last[1]-year_subject_stats.first[1])/
      (year_subject_stats.last[0]-year_subject_stats.first[0])
    end
  end

  def find_usable_yearly_statistics(years, stats)
    years.zip(stats).reject{ |year| !year[1].is_a?(Float)}
  end

  def organize_subject_stats(args)
    @tests[GRADE_MAP[args[:grade]]].values.map do |value|
      Hash[*value.flatten]
    end
  end

  def collect_subject_statistics(subject_stats, args)
    subject_stats.collect do |hash|
      hash[args[:subject]]
    end
  end

  def collect_years(args)
    @tests[GRADE_MAP[args[:grade]]].keys
  end

  def hash_results(heading)
    {
      math: average(heading[0]).round(3),
      reading: average(heading[1]).round(3),
      writing: average(heading[2]).round(3)
    }
  end

  def check_for_na(heading)
    heading[0] = [0] if heading[0].empty?
    heading[1] = [0] if heading[1].empty?
    heading[2] = [0] if heading[2].empty?
  end

  def map_subject_for_average(grade,heading)
    @tests[GRADE_MAP[grade]].values.map do |v|
      map_statistics_per_subject(v, heading)
    end
  end

  def map_statistics_per_subject(v, heading)
    v.each do |subject|
      heading[0] << subject[1] if
      subject[0] == :math && subject[1].is_a?(Float)
      heading[1] << subject[1] if
      subject[0] == :reading  && subject[1].is_a?(Float)
      heading[2] << subject[1] if
      subject[0] == :writing && subject[1].is_a?(Float)
    end
  end

  def add_headings(value)
    values = {}
    add_each_heading(value, values)
    values
  end

  def add_each_heading(value, values)
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
      Hash[value.map{ |k, v| [k, round_if_float(v)] }]
    end
  end

  def round_if_float(value)
    if value.is_a?(Float)
      value.round(3)
    else
      value
    end
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