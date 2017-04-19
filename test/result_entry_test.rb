require_relative 'test_helper'
require_relative '../lib/result_entry'

class ResultEntryTest < Minitest::Test

  def test_it_exists
    r1 = ResultEntry.new({free_and_reduced_price_lunch_rate: 0.5,
      children_in_poverty_rate: 0.25, high_school_graduation_rate: 0.75})
      assert_instance_of ResultEntry, r1
  end

  def test_can_store_data_in_hash
    r1 = ResultEntry.new({free_and_reduced_price_lunch_rate: 0.5,
      children_in_poverty_rate: 0.25, high_school_graduation_rate: 0.75})
      actual = r1.results
      expected = {free_and_reduced_price_lunch_rate: 0.5,
        children_in_poverty_rate: 0.25, high_school_graduation_rate: 0.75}
    assert_equal expected, actual
  end

  def test_it_can_return_free_of_reduced_price_lunch
    r1 = ResultEntry.new({free_and_reduced_price_lunch_rate: 0.5,
      children_in_poverty_rate: 0.25, high_school_graduation_rate: 0.75})
      actual = r1.free_and_reduced_price_lunch_rate
      expected = 0.5
      assert_equal expected, actual
  end

  def test_returns_nil_with_missing_key
    r1 = ResultEntry.new({})
    assert_nil r1.free_and_reduced_price_lunch_rate
  end

  def test_it_can_return_children_in_poverty_rate
    r1 = ResultEntry.new({free_and_reduced_price_lunch_rate: 0.5,
      children_in_poverty_rate: 0.25, high_school_graduation_rate: 0.75})
      actual = r1.children_in_poverty_rate
      expected = 0.25
      assert_equal expected, actual
  end

  def test_it_can_return_high_school_graduation_rate
    r1 = ResultEntry.new({free_and_reduced_price_lunch_rate: 0.5,
      children_in_poverty_rate: 0.25, high_school_graduation_rate: 0.75})
      actual = r1.high_school_graduation_rate
      expected = 0.75
      assert_equal expected, actual
  end

  def test_it_can_return_median_household_income
    r1 = ResultEntry.new({free_and_reduced_price_lunch_rate: 0.5,
      children_in_poverty_rate: 0.25, high_school_graduation_rate: 0.75,
      median_household_income: 50_000})
      actual = r1.median_household_income
      expected = 50_000
      assert_equal expected, actual
  end            
end