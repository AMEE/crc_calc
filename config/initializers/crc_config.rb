module CRC

  #
  # A repository for data liable to change or whose value is not clearly defined
  #
  module Config
    
    def self.min_electricity_usage
      6_000_000
    end
    
    def self.co2_to_cost co2
      ((co2.to_f / 1000) * 12)
    end
  
    def self.standards_ref_date
      Time.parse "2010-04-01"
    end
  
  end
  
end
