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
end