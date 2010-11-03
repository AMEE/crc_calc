class CalculatorController < ApplicationController

  # We want all number formatting to be the same. As we can't render json 
  # partials, we include the following here for consistent formatting.
  include CalculatorHelper  
  include ActionView::Helpers::NumberHelper
  
  before_filter :create_or_retrieve_profile
  
  def index
    @fuel_entries = ordered_fuel_entries        
    
    @cd = ClientDetail.retrieve_all profile
    @client_detail = ClientDetail.find_by_profile_id profile
    @crc_status = @cd[:crc_status]
    @hhmr = @cd[:hhm_reading]
    @section = (params[:section] || 'about').to_sym
    render
  end
  
  def co2
    amee_params = derive_params params[:val], params[:unit]
    co2, pi_id = query_amme params[:drill], amee_params
    cost = FuelEntry.cost co2

    FuelEntry.selective_store :profile_id => profile, :profile_item_id => pi_id, 
      :drill => params[:drill], :value => params[:val].to_f, :unit => params[:unit], 
      :co2 => co2.to_f, :cost => cost
      
    cd = ClientDetail.retrieve_all profile
    data = {:co2 => co2, :cost => cost}.merge cd

    [:co2, :cost, :total_co2, :total_cost].each do |sym|
      data[sym] = fmt_no data[sym]
    end        
    render :json => data
  end
  
  def edit_details
    @client_detail = ClientDetail.find_by_profile_id profile
    @client_detail.name = params[:name] unless params[:name] == 'Your Name'
    @client_detail.email = params[:email] unless params[:email] == 'Your Email'
    @client_detail.org_name = params[:org_name] unless params[:org_name] == 'Your Org Name'
    @client_detail.save!
    redirect_to :action => 'index', :section => 'calculator'
  end

  def hhmr 
    hhmr = params[:hhmr]
    
    cd = ClientDetail.find_by_profile_id profile
    cd.hhm_reading = hhmr
    cd.save!
    
    data = ClientDetail.retrieve_all profile
    render :json => data
  end
  
  def query_amme drill, parameters
    category = "/business/energy/stationaryCombustion/crc"
                
    entry = FuelEntry.find_by_profile_id_and_drill(profile, drill)
    pi_id = entry ? entry.profile_item_id : nil
    
    if pi_id
      item = AMEE::Profile::Item.update(global_amee_connection, "/profiles/#{profile}#{category}/#{pi_id}", parameters)
    else
      uid = AMEE::Data::DrillDown.get(global_amee_connection, "/data#{category}/drill?#{drill}").data_item_uid
      item = AMEE::Profile::Item.create_without_category(global_amee_connection, "/profiles/#{profile}#{category}", uid, parameters)
    end
        
    unit = item.total_amount_unit
    raise "AMEE returned #{unit} - kg/year expected" unless unit == "kg/year"
    
    return item.total_amount, item.uid
  end
  
  def create_or_retrieve_profile
    profile_from_request || profile_from_session
  end
  
  def profile_from_request
    if params[:guid]
      detail = ClientDetail.find_by_guid params[:guid]
      unless detail
        profile_id = AMEE::Profile::Profile.create(global_amee_connection).uid
        detail = ClientDetail.create :profile_id => profile_id, :guid => params[:guid]
      end
      session[:profile_id] = detail.profile_id
    end
  end
    
  def profile_from_session    
    profile_id = session[:profile_id]
    
    if profile_id.nil?
      profile_id = AMEE::Profile::Profile.create(global_amee_connection).uid
      detail = ClientDetail.create :profile_id => profile_id, :guid => profile_id
      session[:profile_id] = detail.profile_id
    end
    session[:profile_id]
  end
    
  def profile
    session[:profile_id]
  end
    
  def league_table
    lt = FuelEntry.league_table
  
    @rank, @entry = FuelEntry.rank_and_entry lt, profile
    if @rank.nil?
      render :partial => "unranked"
    else
      @best, @worst = FuelEntry.skel(lt[0]), FuelEntry.skel(lt[-1])
      @size = lt.size
      render :partial => "league_table"
    end
  end
  
  def web_report    
    @client_detail = ClientDetail.find_by_profile_id profile
    if @client_detail.org_name.nil?
      render :partial => "no_details"
    else
      @ref_date = CRC::Config.standards_ref_date

      @fuel_entries = ordered_fuel_entries
      lt = FuelEntry.league_table
      @rank, @entry = FuelEntry.rank_and_entry lt, profile
      @rank = "unranked" if @rank.nil?

      render :partial => 'web_report'
    end
  end
  
  def pdf_report
    @client_detail = ClientDetail.find_by_profile_id profile
    lt = FuelEntry.league_table  
    @rank, @entry = FuelEntry.rank_and_entry lt, profile
    @rank = "unranked" if @rank.nil?            
    @breakdown = ordered_fuel_entries
    
    pdf = Pdf::Report.new.generate @client_detail.org_name, params[:gen_date], params[:ref_date], @rank, @entry, @breakdown
    
    opts = {:filename => "crc.pdf", :type => "application/pdf", :disposition => "attachment"}
    send_data pdf.render, opts
  end
  
  #
  # Expected units 
  #   - energy Wh 
  #   - volume L 
  #   - mass Kg 
  #
  def derive_params value, unit
    h = {
      "Wh" => "energyUsed",
      "L" => "volumeUsed",
      "kg" => "massUsed",
      "t" => "massUsed",
    }
    form = h.find { |k,v| unit =~ /#{k}$/ }[1]
    {form => value, "#{form}Unit" => unit}
  end
  
  def clear_session
    reset_session
    redirect_to "/"
  end
    
  def ordered_fuel_entries
    fes = FuelEntry.find_all_by_profile_id profile
    energy_types.map do |et| 
      drill = FuelEntry.drill_from_name et[:name]
      entry = fes.find { |e| e.drill == drill }
      entry ? entry : FuelEntry.new(:drill => drill, :unit => et[:unit])
    end
  end
      
  def energy_types
    [
      {:name => "electricity",            :unit => "kWh"},
      {:name => "natural gas",            :unit => "kWh"},
      {:name => "petrol",                 :unit => "L"  },
      {:name => "diesel",                 :unit => "L"  },
      {:name => "fuel oil",               :unit => "t" },
                                                        
      {:name => "blast furnace gas",      :unit => "kWh"},
      {:name => "coke oven gas",          :unit => "kWh"},
      {:name => "colliery methane",       :unit => "kWh"},
      {:name => "other petroleum gas",    :unit => "kWh"},
      {:name => "sour gas",               :unit => "kWh"},
                                                        
      {:name => "aviation spirit",        :unit => "t" },
      {:name => "aviation turbine fuel",  :unit => "t" },
      {:name => "coking coal",            :unit => "t" },
      {:name => "industrial coal",        :unit => "t" },
      {:name => "waste",                  :unit => "t" },
      {:name => "naphtha",                :unit => "t" },
      {:name => "petroleum coke",         :unit => "t" },
      {:name => "scrap tyres",            :unit => "t" },
      {:name => "solid smokeless fuel",   :unit => "t" },
      {:name => "waste solvents",         :unit => "t" },
                                                        
      {:name => "gas oil",                :unit => "L"  },
      {:name => "lpg",                    :unit => "L"  },
      {:name => "burning oil/kerosene/paraffin", :unit => "L"}
    ]
  end    
  
end
