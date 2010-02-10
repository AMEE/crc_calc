module CalculatorHelper
  
  def name name
    name.split(/[ \/]/).map { |t| t.capitalize }.join(" ")
  end
  
  def n_to_s name
    name.downcase.gsub(" ", "-").gsub("/", "-")
  end
    
  def drill name
    "fuel=#{CGI::escape name}"
  end
  
  def fmt_no n
    number_with_precision n, :precision => 0, :delimiter => ","
  end
  
  # Selectively display the outside CRC header
  def display_outside_crc
    entry = @fuel_entries.find { |e| e.drill == "fuel=electricity" }
    display = entry && entry.value ? (entry.value < 6_000_000 ? "block" : "none") : "none"
    "style='display:#{display}'"
  end
  
  def formatted_times t
    [
      t.strftime("%Y-%m-%d"),
      t.strftime("%d/%m/%Y"),
      t.strftime("%d/%m/%y"),
      t.strftime("%m/%d/%y"),
      t.strftime("%B %d, %Y")
    ]
  end
  
  def js_time_hash ref_date
    now, ref = formatted_times(Time.now), formatted_times(ref_date)
    arr = []
    now.each_index do |i|
      arr << "'#{now[i]}': '#{ref[i]}'"
    end
    arr.join ",\n"
  end
  
  def crc_stat_vis status, sym
    d = status == sym ? "block" : "none"
    "style='display: #{d};'"
  end
    
end
