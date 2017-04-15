require 'pry'
class HeadcountAnalyst
  attr_reader :district_repository

  def initialize(district_repository)
    @district_repository = district_repository
  end

  def kindergarten_participation_rate_variation(comparison, base)
    comparison = district_kindergarten_participation(comparison).values
    base = district_kindergarten_participation(base[:against]).values
    rate_variation(comparison, base)
  end

  def kindergarten_participation_rate_variation_trend(comparison, base)
    comparison_values = district_kindergarten_participation(comparison)
    base_values = district_kindergarten_participation(base[:against])
    statistical_average_per_year(comparison_values, base_values)
  end

  def kindergarten_participation_against_high_school_graduation(district)
    kinder_part_var =
    kindergarten_participation_rate_variation(district, :against => 'COLORADO')
    hs_grad_var = high_school_graduation_variation(district)
    variation_quotient(kinder_part_var, hs_grad_var)
  end

  def high_school_graduation_variation(district)
    base = graduation_rate_by_year("COLORADO")
    comparison = graduation_rate_by_year(district)
    rate_variation(comparison.values, base.values)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(district)
    if district[:across]
      kindergarten_participation_correlates_with_high_school_graduation_across_districts(district[:across])
    elsif district[:for] == "STATEWIDE"
      kindergarten_participation_correlates_with_high_school_graduation_across_districts(all_districts)
    else
      kindergarten_participation_correlates_with_high_school_graduation_per_district(district[:for])
    end
  end

  def kindergarten_participation_correlates_with_high_school_graduation_per_district(district)
    participations =
    kindergarten_participation_against_high_school_graduation(district)
    participation_correlated?(participations)
  end

  def kindergarten_participation_correlates_with_high_school_graduation_across_districts(districts)
    correlation = districts.map do |district|
      kindergarten_participation_correlates_with_high_school_graduation(for: district)
    end
    participations_correlated?(correlation)
  end

  def top_statewide_test_year_over_year_growth(args)
    valid_grades = [3, 8]
    raise InsufficientInformationError unless valid_grades.include?(args[:grade])
    if args[:top] && args[:grade]
      statewide_test_year_over_year_growth(args).shift(args[:top])
    elsif args[:grade] && args[:subject]
      statewide_test_year_over_year_growth(args).shift
    else
      top_statewide_test_year_over_year_growth_across_subjects(args)
    end
  end

  def top_statewide_test_year_over_year_growth_across_subjects(args)
    all_stats = find_all_subject_stats(args)
    weighted_stats = weight_stats(args, all_stats)
    combined_stats = cross_subject_statistics(weighted_stats)
    round_stats(combined_stats).shift
  end

###############################################


  def statewide_average_free_reduced_lunch(year=2014)
    state_statistics = state_economic_statistics(:free_or_reduced_price_lunch)
    total = state_statistics.each_value.map{ |v| v[:total] }
    determine_average(total, state_statistics)
  end

  def districts_over_state_avg_free_reduced_lunch
    all = map_districts_lunch_data
    collect_districts_over_state_avg_for_free_reduced_lunch(all)
  end

  def statewide_school_age_poverty
    stats = @district_repository.districts.keys.map do |key|
      key == "COLORADO"? next : district_avg_school_age_poverty(key)
    end
    average(stats.compact, stats)
  end

  def district_avg_school_age_poverty(district)
    stats = @district_repository.districts[district].economic_profile.economic_profile[:children_in_poverty]
    average(stats.values, stats.keys)
  end

  private

  def collect_districts_over_state_avg_for_free_reduced_lunch(all)
    all.compact.collect do |stat|
      @district_repository.districts[stat[0]] if stat[1] > statewide_average_free_reduced_lunch
    end
  end

  def map_districts_lunch_data
    @district_repository.economic_profile_repository.profiles.map do |k,v|
      k == "COLORADO" ? next : [k, average_across_years(v)]
    end
  end

  def average_across_years(v)
    profile = v.economic_profile[:free_or_reduced_price_lunch]
    totals = profile.each_value.map do |v|
      v[:total]
    end
    average(totals, profile.keys)
  end

  def determine_average(total, state_statistics)
    ((total.inject(:+)/ state_statistics.keys.count)/(@district_repository.districts.keys.count - 1)).round(3)
  end

  def state_economic_statistics(study)
    @district_repository.economic_profile_repository.profiles["COLORADO"].economic_profile[study]
  end

  def weight_stats(args, all)
    if args[:weighting]
      all = weight_statistics(args, all) 
      all[:divisor] = 1
    else
      all[:divisor] = 3
    end
    all 
  end

  def find_all_subject_stats(args)
    math = find_subject_stats(args, "math")
    reading = find_subject_stats(args, "reading")
    writing = find_subject_stats(args, "writing")
    {math: math, reading: reading, writing: writing}
  end

  def weight_statistics(args, all)
    math = apply_weighting(all[:math], args[:weighting][:math])
    reading = apply_weighting(all[:reading], args[:weighting][:reading])
    writing = apply_weighting(all[:writing], args[:weighting][:writing])
    {math: math, reading: reading, writing: writing}
  end

  def cross_subject_statistics(all)
    all[:math].zip(all[:reading]).zip(all[:writing]).map{|a| (a.flatten.inject(:+)/all[:divisor])}
  end

  def apply_weighting(stats, weight)
    stats.map{|stat| stat * weight}
  end

  def round_stats(all)
    map_growth_stats(all).each{|val| val[1] = val[1].round(3)}
  end

  def find_subject_stats(args, subject)
    new_arg = {grade: args[:grade], subject: subject.to_sym}
    compile_subject_data(new_arg)
  end

  def statewide_test_year_over_year_growth(args)
    percent_growth = compile_subject_data(args)
    round_stats(percent_growth)
  end

  def compile_subject_data(args)
    subject_stats_per_district =  subject_stats_per_district(args)
    valid_statistics = valid_stats(subject_stats_per_district)
    calculate_growth(valid_statistics)
  end

  def map_growth_stats(percent_growth)
    all_districts.zip(percent_growth).sort_by do |array|
      array[1]
    end.reverse
  end

  def calculate_growth(valid_statistics)
    valid_statistics.map do |stats|
      if stats.empty? || stats.count == 1
        0.0
      else
        (stat_diff(stats)/ year_diff(stats))
      end
    end
  end

  def valid_stats(all_stats)
    all_stats.map do |stats|
      collect_valid_statistic(stats)
    end
  end

  def subject_stats_per_district(args)
    @district_repository.districts.values.collect do |value|
      proficiency_for_subject_in_all_years(args, value)
    end
  end
  def proficiency_for_subject_in_all_years(args, value)
    (2008..2014).collect do |number|
      [number, value.testing.proficient_for_subject_by_grade_in_year(args[:subject],args[:grade], number)]
    end
  end

  def collect_valid_statistic(array)
    array.select do |value|
      value[1].is_a?(Float) || value[1].is_a?(Integer)
    end
  end

  def stat_diff(stat)
    (stat[-1][1] - stat[0][1])
  end

  def year_diff(stat)
    (stat[-1][0] - stat[0][0])
  end

  def all_districts
    @district_repository.districts.keys
  end

  def participations_correlated?(correlation)
    (correlation.count(true).to_f/correlation.length.to_f) > 0.70
  end

  def participation_correlated?(correlation)
    correlation.nil? || !correlation.between?(0.6, 1.5) ? false : true
  end

  def graduation_rate_by_year(district)
    district_repository.find_by_name(district)
    .enrollment.graduation_rate_by_year
  end

  def rate_variation(comparison, base)
    comparison = comparison.reject{|value| !value.is_a?(Float)}
    base = base.reject{|value| !value.is_a?(Float)}
    if comparison.empty?|| base.empty?
      return
    else
      (generate_yearly_statistical_average(comparison)/
      generate_yearly_statistical_average(base)).round(3)
    end
  end

  def variation_quotient(kinder_part_var, hs_grad_var)
    if hs_grad_var.nil?|| hs_grad_var.zero?
      return nil
    else
      (kinder_part_var/hs_grad_var).round(3)
    end
  end

  def statistical_average_per_year(comp_values, base_values)
    comp_values =
    comp_values.merge(base_values){ |key, comp, base| (comp/base).round(3) }
    comp_values.sort.to_h
  end

  def generate_yearly_statistical_average(district_values)
    average(district_values, district_values)
  end

  def average(values_a, values_b)
    (values_a.inject(:+)/values_b.length).round(3)
  end

  def district_kindergarten_participation(district)
    district = district_repository.find_by_name(district)
    district.enrollment.kindergarten_participation_by_year
  end
end
