module Statistics
  def average(data)
    (data.inject(:+)/data.count)
  end

  def average_and_round(yearly)
    if yearly.empty?
      nil
    else
      average(yearly).round(3)
    end
  end

  def variation_quotient(variation_a, variation_b)
    if variation_b.nil?|| variation_b.zero?
      return nil
    else
      (variation_a/variation_b).round(3)
    end
  end

  def compare_averages(comparison, base)
    (average(comparison)/average(base)).round(3)
  end

  def statistical_average_per_year(comp_values, base_values)
    comp_values =
    comp_values.merge(base_values){ |key, comp, base| (comp/base).round(3) }
    comp_values.sort.to_h
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
  
  def participations_correlated?(correlation)
    (correlation.count(true).to_f/correlation.length.to_f) > 0.70
  end

  def participation_correlated?(correlation)
    correlation.nil? || !correlation.between?(0.6, 1.5) ? false : true
  end
end