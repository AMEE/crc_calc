class FuelEntry < ActiveRecord::Base
  
  #
  # The drill is the canonical identifier within AMEE of the fuel type.
  #
  # The human readable name returned by this method will be different (by case at
  # least) from the canonical name required by the drill_from_name method below.
  #
  def hr_name
    drill =~ /fuel=/
    name = CGI::unescape $'
    name.split(" ").map { |t| t.capitalize }.join(" ")
  end
  
  def self.drill_from_name name
    "fuel=#{CGI::escape name}"
  end  
    
  def self.league_table
    query = "select profile_id, sum(co2) as co2_total from fuel_entries group by profile_id order by co2_total asc;"
    result = connection.select_rows query
    result.each { |r| r[1] = r[1].to_i }
  end
  
  #
  # Position is for the end user - increment array index by one
  #
  def self.rank_and_entry league_table, profile_id
    league_table.each_with_index do |e, i|
      if e[0] == profile_id
        return i + 1, FuelEntry.skel(e)
      end
    end
    return nil, FuelEntry.new
  end 
  
  # Choosing an unusual name for now so I don't accidentally step on ARs toes
  def self.selective_store data
    entry = FuelEntry.find_by_profile_id_and_drill data[:profile_id], data[:drill]
    if entry
      entry.update_attributes data
    else
      FuelEntry.create data
    end
  end
  
  #
  # Returns a minimal FuelEntry for display only, based on a league_table row
  #
  def self.skel e
    new :profile_id => e[0], :co2 => e[1], :cost => cost(e[1])
  end
  
  #
  # This is the only place in the CRC calculator where cost is calculated
  #
  def self.cost co2
    CRC::Config.co2_to_cost co2
  end
  
  #
  # I'd rather not let these strings leak out
  #  
  def self.electricity_drill
    "fuel=electricity"
  end
  
end
