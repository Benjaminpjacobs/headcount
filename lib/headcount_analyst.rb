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
    base = base[:against]
    comparison_values = district_kindergarten_participation(comparison)
    base_values = district_kindergarten_participation(base)
    comparison_values.merge(base_values) { |key, c_value, b_value| (c_value/b_value).round(3)}.sort.to_h
  end

  private

  def generate_yearly_statistical_average(district)
    district_values = district_kindergarten_participation(district).values
    district_stat = (district_values.inject(&:+)/district_values.length).round(3)
  end

  def district_kindergarten_participation(district)
    district = district_repository.find_by_name(district)
    district.enrollments.kindergarten_participation_by_year
  end

end
