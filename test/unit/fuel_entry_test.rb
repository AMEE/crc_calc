require 'test_helper'

class FuelEntryTest < ActiveSupport::TestCase

  test "league_table" do
    assert_equal [["hemp_hugger", 3], ["polluticon", 30]], FuelEntry.league_table
  end
  
  test "rank_and_entry" do
    rank, entry = FuelEntry.rank_and_entry([["hemp_hugger", 3], ["polluticon", 30]], "hemp_hugger")
    assert_equal 1, rank
    assert_equal 3, entry.co2
    assert_in_delta 0.036, entry.cost, 0.1
  end

  test "rank_and_entry when no data exists" do
    rank, entry = FuelEntry.rank_and_entry([["hemp_hugger", 3], ["polluticon", 30]], "foo")
    assert_equal nil, rank
    assert_equal nil, entry.co2
  end
  
  test "selective_store should create or update" do
    data = {:profile_id => "p", :drill => "d", :value => 1, :unit => "u", :co2 => 2}
    
    assert_equal [], FuelEntry.find_all_by_profile_id_and_drill("p", "d")
    
    entry = FuelEntry.selective_store data    
    assert_equal [entry], FuelEntry.find_all_by_profile_id_and_drill("p", "d")
    
    data[:value] = 5
    FuelEntry.selective_store data
    assert_equal 5, FuelEntry.find(entry.id).value
  end
    
end
