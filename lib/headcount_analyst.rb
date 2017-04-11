class HeadcountAnalyst
  attr_reader :district_repository

  def initialize(district_repository)
    @district_repository = district_repository
  end

  def kindergarten_participation_rate_variation(comparison, base)
    base = base[:against]
    (generate_yearly_statistical_average(comparison)/
    generate_yearly_statistical_average(base)).round(3)
  end

  def kindergarten_participation_rate_variation_trend(comparison, base)
    comparison = district_repository.find_by_name(comparison)
    comparison_values = comparison.enrollments.kindergarten_participation_by_year
    base = base[:against]
    base = district_repository.find_by_name(base)
    base_values = base.enrollments.kindergarten_participation_by_year
    comparison_values.merge(base_values) { |key, c_value, b_value| (c_value/b_value).round(3)}.sort.to_h
  end

  private

  def generate_yearly_statistical_average(district)
    district = district_repository.find_by_name(district)
    district_values = district.enrollments.kindergarten_participation_by_year.values
    district_stat = (district_values.inject(&:+)/district_values.length).round(3)
  end


end
