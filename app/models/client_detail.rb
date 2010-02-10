class ClientDetail < ActiveRecord::Base
  
  # extend ActionView::Helpers::NumberHelper
  # extend CalculatorHelper
    
  def self.crc_status elec_kwh, hhm_reading
    if elec_kwh.nil?
      :first_run
    elsif elec_kwh >= CRC::Config.min_electricity_usage
      hhm_reading ? :full_participant : :exempt_hhm
    else
      hhm_reading ? :exempt_elec : :exempt_both
    end
  end  
    
  def self.retrieve_all profile_id
    fes = FuelEntry.find_all_by_profile_id profile_id
    cost = fes.inject(0) { |a,e| a + e.cost }
    co2 = fes.inject(0) { |a,e| a + e.co2 }

    cd = ClientDetail.find_by_profile_id profile_id
    fe = fes.find { |e| e.drill == FuelEntry.electricity_drill }
    cs = crc_status((fe && fe.value), cd.hhm_reading)
    
    {:total_cost => cost, :total_co2 => co2, 
      :crc_status => cs, :hhm_reading => cd.hhm_reading}
  end
  
end
