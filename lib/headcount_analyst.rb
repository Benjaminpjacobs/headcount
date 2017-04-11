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
    (high_school_graduation_variation(district)/
    kindergarten_participation_rate_variation(district, :against => 'COLORADO')).round(3)
  end

  def high_school_graduation_variation(district)
    binding.pry
    base = district_repository.find_by_name("COLORADO").enrollments.graduation_rate_by_year
    comparison = district_repository.find_by_name(district).enrollments.graduation_rate_by_year
    (generate_yearly_statistical_average(comparison.values) / 
    generate_yearly_statistical_average(base.values)).round(3)
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
    district.enrollments.kindergarten_participation_by_year
  end

end
