class HeadcountAnalyst
  attr_reader :district_repository

  def initialize(district_repository)
    @district_repository = district_repository
  end

  def kindergarten_participation_rate_variation(comparison, base)
    base = base[:against]
    comparison = district_kindergarten_participation(comparison).values
    base = district_kindergarten_participation(base).values
    (generate_yearly_statistical_average(comparison)/
    generate_yearly_statistical_average(base)).round(3)
  end

  def kindergarten_participation_rate_variation_trend(comparison, base)
    base = base[:against]
    comparison_values = district_kindergarten_participation(comparison)
    base_values = district_kindergarten_participation(base)
    statistical_average_per_year(comparison_values, base_values)
  end

  def kindergarten_participation_against_high_school_graduation(district)
    kinder_part_var = kindergarten_participation_rate_variation(district, :against => 'COLORADO')
    hs_grad_var = high_school_graduation_variation(district)
    if hs_grad_var.zero?
      return nil
    else
      (kinder_part_var/hs_grad_var).round(3)
    end
  end

  def high_school_graduation_variation(district)
    base = district_repository.find_by_name("COLORADO").enrollment.graduation_rate_by_year
    comparison = district_repository.find_by_name(district).enrollment.graduation_rate_by_year
    (generate_yearly_statistical_average(comparison.values) / 
    generate_yearly_statistical_average(base.values)).round(3)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(district)
    if district[:across]
      kindergarten_participation_correlates_with_high_school_graduation_across_districts(district[:across])
    elsif district[:for] == "STATEWIDE"
      compile_statewide_participation_correlation
    else
      kindergarten_participation_correlates_with_high_school_graduation_per_district(district[:for])
    end
  end

  def kindergarten_participation_correlates_with_high_school_graduation_per_district(district)
    correlation = kindergarten_participation_against_high_school_graduation(district)
    if correlation.nil? || !correlation.between?(0.6, 1.5)
      false
    else
      true
    end
  end

  def kindergarten_participation_correlates_with_high_school_graduation_across_districts(districts)
    correlation = districts.map do |district|
      kindergarten_participation_correlates_with_high_school_graduation(for: district)
    end
     (correlation.count(true).to_f/correlation.length.to_f) > 0.70 
  end
  

  def compile_statewide_participation_correlation
    correlation = @district_repository.districts.each_key.map do |key|
      kindergarten_participation_correlates_with_high_school_graduation(for: key)
    end
    (correlation.count(true).to_f/correlation.length.to_f) > 0.70 
  end

  private

  def statistical_average_per_year(comparison_values, base_values)
    comparison_values.merge(base_values) { |key, c_value, b_value| (c_value/b_value).round(3)}.sort.to_h  
  end

  def generate_yearly_statistical_average(district_values)
    (district_values.inject(&:+)/district_values.length).round(3)
  end

  def district_kindergarten_participation(district)
    district = district_repository.find_by_name(district)
    district.enrollment.kindergarten_participation_by_year
  end

end
