require 'pry'
require_relative 'result_set'
require_relative 'result_entry'

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

  def top_statewide_test_year_over_year_growth(args)
    args[:top] = 1 if args[:top].nil?
    districts = all_districts_year_over_year_growth(args)
    top = map_top_districts(args, districts)
    top.flatten! if top.count == 1
    top
  end

  def over_state_average(key)
    all_dist_stats = all_district_statistics(key)
    state_avg =  average(all_dist_stats, all_dist_stats)
    districts = individual_district_names
    results = collect_stat_over_average(districts, all_dist_stats, state_avg)
    format_results(results, :high_school_graduation_rate)
  end

  def create_result_set(arg)
    studies = all_study_data(arg)
    common = collect_district_names_in_common(studies, arg)
    districts = prep_result_entries(common, studies)
    average = ResultEntry.new(prep_statewide_average(arg))
    ResultSet.new({matching_districts: districts, statewide_average: average})
  end

  def high_poverty_and_high_school_graduation
    create_result_set([:lunch, :poverty, :graduation])
  end

  def high_income_disparity
    create_result_set([:poverty, :income])
  end

  def kindergarten_participation_against_household_income(district)
    kindergarten_variation = study_variation(district, :kindergarten)
    income_variation = study_variation(district, :income)
    return 0.0 if income_variation.zero?
    (kindergarten_variation/income_variation).round(3)
  end

  def study_variation(district, study)
    state_avg = state_average(study)
    district_avg = study_data(district, study)
    (district_avg/state_avg)
  end

  def study_data(district, study)
    studies=
      {
        kindergarten: @district_repository.districts[district].enrollment.kindergarten_participation_average,
        income: @district_repository.districts[district].economic_profile.median_household_income_average
      }
    studies[study]
  end

  def state_average(key)
    all_dist_stats = all_district_statistics(key)
    average(all_dist_stats, all_dist_stats)
  end

  def kindergarten_participation_correlates_with_household_income(args)
    if args[:for] == "STATEWIDE"
      across_district_correlation(individual_district_names)
    elsif args[:across] 
      across_district_correlation(args[:across])
    else
      correlation = kindergarten_participation_against_household_income(args[:for])
      participation_correlated?(correlation)
    end    
  end

  def across_district_correlation(args)
    correlation = args.map do |name|
      kindergarten_participation_correlates_with_household_income(for: name)
    end
    participations_correlated?(correlation)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(district)
    if district[:for] == "STATEWIDE"
      kindergarten_participation_correlates_with_high_school_graduation_across_districts(all_districts)
    elsif district[:across]
      kindergarten_participation_correlates_with_high_school_graduation_across_districts(district[:across])
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
  
  private

  def prep_statewide_average(studies)
    state_avg = {}
    studies.each do |study|
      which_average(state_avg, study)
    end
    state_avg
  end

  def which_average(state_avg, study)
    which_average = 
      {
        lunch: state_avg[:free_and_reduced_price_lunch_rate] = 
        average(all_district_statistics(study),all_district_statistics(study)),
        poverty: state_avg[:children_in_poverty_rate] = 
        average(all_district_statistics(study),all_district_statistics(study)),
        graduation: state_avg[:high_school_graduation_rate] = 
        average(all_district_statistics(study),all_district_statistics(study)),
        income: state_avg[:median_household_income] = 
        average(all_district_statistics(study),all_district_statistics(study))
      }
    which_average[study]
  end

  def prep_result_entries(common, studies)
    common.map do |district|
      results = {}
      results[:name] = district
      results[:free_and_reduced_price_lunch_rate] = 
      studies[:lunch][district] if studies[:lunch]
      results[:children_in_poverty_rate] = 
      studies[:poverty][district] if studies[:poverty]
      results[:high_school_graduation_rate] = 
      studies[:graduation][district] if studies[:graduation]
      results[:median_household_income] = 
      studies[:income][district] if studies[:income] 
      ResultEntry.new(results)
    end  
  end
    
  def format_results(results, _study)
    Hash[*results.collect{|h| h.to_a}.flatten]
  end

  def collect_district_names_in_common(studies, args)
    compare = compile_studies(studies, args)
    intersection(args, compare)
  end

  def intersection(args, compare)
    if args.length == 2
      compare[0] & compare[1]
    else  
      compare[0] & compare[1] & compare[2]
    end
  end

  def compile_studies(studies, args)
    args.map do |arg|
      studies[arg].keys
    end
  end

  def all_study_data(args)
    study_data = {}
    args.each do |arg|
      study_data[arg] = over_state_average(arg)
    end
    study_data
  end
    
  def all_district_statistics(study)
    @district_repository.districts.each.collect do |key, value|
      next if key_co?(key)
      which_profile(study, value)
    end.compact
  end

  def which_profile(study, value)
    which_profile = 
      {
        lunch: value.economic_profile.free_or_reduced_price_lunch_number_average,
        poverty: value.economic_profile.children_in_poverty_average,
        graduation: value.enrollment.graduation_rate_average,
        income: value.economic_profile.median_household_income_average,
        kindergarten: value.enrollment.kindergarten_participation_average
      }
    which_profile[study]
  end
 
  def key_co?(key)
    key == "COLORADO"
  end

  def individual_district_names
    districts = all_districts
    districts.delete("COLORADO")
    districts
  end

  def collect_stat_over_average(districts, all_dist_stats, state_avg)
    districts.zip(all_dist_stats).select do |district|
      next if district[1].nil?
      district[1] > state_avg
    end.compact
  end

  def map_top_districts(args, districts)
    (1..args[:top]).map do
      district = districts.shift
      district[1] = district[1].round(3)
      district
    end
  end

  def all_districts_year_over_year_growth(args)
    test_statistics = return_district_test_statistics(args)
    sort_district_results(all_districts, test_statistics)
  end

  def across_or_per_subject(value, args)
    if args[:subject].nil?
      value.statewide_test.year_over_year_growth_across_subject(args)
    else
      value.statewide_test.year_over_year_growth_per_subject(args)
    end
  end  

  def return_district_test_statistics(args)
    @district_repository.districts.values.map do |value|
      across_or_per_subject(value, args)
    end
  end

  def sort_district_results(keys, values)
    keys.zip(values).sort_by{|stat| stat[1]}.reverse
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
    generate_average_if_not_empty(comparison, base)
  end

  def generate_average_if_not_empty(comparison, base)
    if comparison.empty?|| base.empty?
      return
    else
      compare_averages(comparison, base)
    end
  end

  def compare_averages(comparison, base)
    (generate_yearly_statistical_average(comparison)/
    generate_yearly_statistical_average(base)).round(3)
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