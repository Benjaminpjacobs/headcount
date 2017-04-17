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
    args[:top] = 1 if args[:top].nil?
    districts = all_districts_year_over_year_growth(args)
    top = map_top_districts(args, districts)
    top.flatten! if top.count == 1
    top
  end

  def over_state_avg_free_reduced_lunch
    all_dist_stats = all_district_lunch_statistics
    state_avg = average(all_dist_stats, all_dist_stats)
    districts = individual_district_names
    collect_stat_over_average(districts, all_dist_stats, state_avg)
  end

  def over_state_avg_child_poverty
    all_dist_stats = all_district_child_poverty_statistics
    state_avg = average(all_dist_stats, all_dist_stats)
    districts = individual_district_names
    collect_stat_over_average(districts, all_dist_stats, state_avg)
  end

  def over_state_average_hs_graduation
    all_dist_stats = all_district_hs_grad_stats
    state_avg =  average(all_dist_stats, all_dist_stats)
    districts = individual_district_names
    collect_stat_over_average(districts, all_dist_stats, state_avg)
  end



#########################
  
 

  # def collect_districts_over_state_avg_for_free_reduced_lunch(all)
  #   all.compact.collect do |stat|
  #     @district_repository.districts[stat[0]] if stat[1] > statewide_average_free_reduced_lunch
  #   end
  # end

  # def collect_districts_over_state_avg_for_child_poverty(state_avg)
  #   @district_repository.districts.keys.map do |key|
  #     @district_repository.districts[key] if district_avg_child_poverty(key) > state_avg
  #   end.compact
  # end

  # def map_districts_lunch_data
  #   @district_repository.economic_profile_repository.profiles.map do |k,v|
  #     k == "COLORADO" ? next : [k, average_across_years(v)]
  #   end
  # end

  # def average_across_years(v)
  #   profile = v.economic_profile[:free_or_reduced_price_lunch]
  #   totals = profile.each_value.map do |v|
  #     v[:total]
  #   end
  #   average(totals, profile.keys)
  # end

  # def determine_average(total, state_statistics)
  #   ((total.inject(:+)/ state_statistics.keys.count)/(@district_repository.districts.keys.count - 1)).round(3)
  # end

  # def state_economic_statistics(study)
  #   @district_repository.economic_profile_repository.profiles["COLORADO"].economic_profile[study]
  # end
#####################
  private

    
  def all_district_hs_grad_stats
    @district_repository.districts.each.collect do |key, value|
      next if key == "COLORADO"
      value.enrollment.graduation_rate_average
    end.compact
  end

  def all_district_child_poverty_statistics
    @district_repository.districts.each.collect do |key, value|
      next if key == "COLORADO"
      value.economic_profile.children_in_poverty_average
    end.compact
  end

  def all_district_lunch_statistics
    @district_repository.districts.each.collect do |key, value|
      next if key == "COLORADO"
      value.economic_profile.free_or_reduced_price_lunch_number_average
    end.compact
  end

  def individual_district_names
    districts = all_districts
    districts.delete("COLORADO")
    districts
  end

  def collect_stat_over_average(districts, all_dist_stats, state_avg)
    districts.zip(all_dist_stats).map do |district|
      if district[1].nil?
        next
      else
        @district_repository.districts[district[0]] if district[1] > state_avg
      end
    end.compact
  end

  def map_top_districts(args, districts)
    (1..args[:top]).map do |x|
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
