require 'test_helper'

class ClientDetailTest < ActiveSupport::TestCase

  test "crc_status" do
    assert_equal :full_participant, ClientDetail.crc_status(6_000_000, true)
    assert_equal :exempt_hhm, ClientDetail.crc_status(6_000_000, false)
    assert_equal :exempt_elec, ClientDetail.crc_status(1, true)
    assert_equal :exempt_both, ClientDetail.crc_status(1, false)
    assert_equal :first_run, ClientDetail.crc_status(nil, true)
    assert_equal :first_run, ClientDetail.crc_status(nil, false)
  end
  
  test "retrieve_crc_status" do
    assert_equal :exempt_elec, ClientDetail.retrieve_all("hemp_hugger")[:crc_status]
    assert_equal :first_run, ClientDetail.retrieve_all("newbie")[:crc_status]
  end
  
  test "retrieve_all" do
    cd = ClientDetail.retrieve_all "polluticon"
    assert_equal 6, cd[:total_cost]
    assert_equal 30, cd[:total_co2] 
    assert_equal :exempt_elec, cd[:crc_status]
    assert_equal true, cd[:hhm_reading]
  end
  
end
