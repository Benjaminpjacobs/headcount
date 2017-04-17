class ResultSet
  attr_reader :result_entries

  def initialize(result_entries)
    @result_entries = result_entries
  end

  def matching_districts
    @result_entries
  end

  def count
    @result_entries.count
  end

  def first
    @result_entries.first
  end


end
