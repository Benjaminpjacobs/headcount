require_relative 'result_set'
require_relative 'result_entry'

class HeadcountAnalyst
  attr_reader :district_repository

  def initialize(district_repository)
    @district_repository = district_repository
  end

  def kindergarten_participation_rate_variation(comparison, base)
    comparison = district_study(comparison, :kindergarten)
    base = district_study(base[:against] , :kindergarten)
    compare_and_round(comparison, base)
  end

  def kindergarten_participation_rate_variation_trend(comparison, base)
    comparison_values = district_study(comparison, :participation)
    base_values = district_study(base[:against], :participation)
    statistical_average_per_year(comparison_values, base_values)
  end
  
  def high_school_graduation_variation(district)
    study_variation(:graduation, district)
  end

  def kindergarten_participation_against_high_school_graduation(district)
    study_one_against_study_two_for_district(:kindergarten, :graduation, district)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(args)
    if args[:for] == "STATEWIDE"
      correlation_kindergarten_graduation?(individual_district_names)
    elsif args[:across]
      correlation_kindergarten_graduation?(args[:across])
    else
      kindergarten_participation_correlates_with_high_school_graduation_per_district(args[:for])
    end
  end

  def kindergarten_participation_correlates_with_household_income(args)
    if args[:for] == "STATEWIDE"
      correlation_kindergarten_income?(individual_district_names)
    elsif args[:across] 
      correlation_kindergarten_income?(args[:across])
    else
      correlation = kindergarten_participation_against_household_income_per_district(args[:for])
      participation_correlated?(correlation)
    end    
  end

  def kindergarten_participation_against_household_income_per_district(district)
    study_one_against_study_two_for_district(:kindergarten, :income, district)
  end

  def top_statewide_test_year_over_year_growth(args)
    args[:top] = 1 if args[:top].nil?
    districts = all_districts_year_over_year_growth(args)
    top = map_top_districts(args, districts)
    top.flatten! if top.count == 1
    top
  end

  def high_poverty_and_high_school_graduation
    create_result_set([:lunch, :poverty, :graduation])
  end

  def high_income_disparity
    create_result_set([:poverty, :income])
  end


  def over_state_average(key)
    all_dist_stats = all_district_statistics(key)
    state_avg =  state_average(key)
    districts = individual_district_names
    results = collect_stat_over_average(districts, all_dist_stats, state_avg)
    format_results(results, :high_school_graduation_rate)
  end
  
  private

  def create_result_set(arg)
    studies = all_study_data(arg)
    common = collect_district_names_in_common(studies, arg)
    districts = prep_result_entries(common, studies)
    average = ResultEntry.new(prep_statewide_average(arg))
    ResultSet.new({matching_districts: districts, statewide_average: average})
  end

  def study_one_against_study_two_for_district(study_one, study_two, district)
    variation_study_one = study_variation(study_one, district)
    variation_study_two = study_variation(study_two, district)
    return 0.0 if variation_study_two.zero?
    (variation_study_one/variation_study_two).round(3)
  end

  def study_variation(study, district)
    state_avg = check_for_statewide_study(study)
    district_avg = district_study(district, study)
    compare_and_round(district_avg, state_avg)
  end

  def check_for_statewide_study(study)
    if state_wide_study?(study)
      district_study("COLORADO", study)
    else
      state_average(study)
    end
  end

  def state_wide_study?(study)
    district_study("COLORADO", study)
  end

  def state_average(key)
    all_dist_stats = all_district_statistics(key)
    average(all_dist_stats, all_dist_stats)
  end

  def kindergarten_participation_against_household_income(district)
    study_one_against_study_two_for_district(:kindergarten, :income, district)
  end

  def correlation_kindergarten_income?(args)
    correlation = args.map do |name|
      kindergarten_participation_correlates_with_household_income(for: name)
    end
    participations_correlated?(correlation)
  end

  def kindergarten_participation_correlates_with_high_school_graduation_per_district(district)
    correlation =
    kindergarten_participation_against_high_school_graduation(district)
    participation_correlated?(correlation)
  end

  def correlation_kindergarten_graduation?(districts)
    correlation = districts.map do |district|
      kindergarten_participation_correlates_with_high_school_graduation(for: district)
    end
    participations_correlated?(correlation)
  end

  def statistical_average_per_year(comp_values, base_values)
    comp_values =
    comp_values.merge(base_values){ |key, comp, base| (comp/base).round(3) }
    comp_values.sort.to_h
  end

  def compare_and_round(comparison, base)
    comparison.nil? ? 0.0 : (comparison/base).round(3)
  end

  def variation_quotient(kinder_part_var, hs_grad_var)
    if hs_grad_var.nil?|| hs_grad_var.zero?
      return nil
    else
      (kinder_part_var/hs_grad_var).round(3)
    end
  end

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

  def district_study(district, study)
    district_study = 
      {
        kindergarten: @district_repository.districts[district].enrollment.kindergarten_participation_average,
        graduation: @district_repository.districts[district].enrollment.graduation_rate_average,
        income: @district_repository.districts[district].economic_profile.median_household_income_average,
        participation: @district_repository.districts[district].enrollment.kindergarten_participation_by_year
      }
      district_study[study]
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


  def average(values_a, values_b)
    (values_a.inject(:+)/values_b.length).round(3)
  end


end