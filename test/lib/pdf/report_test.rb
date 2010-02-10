require 'test_helper'

class Pdf::ReportTest < ActiveSupport::TestCase

  test "convenience for visual testing of PDFs" do
    total = FuelEntry.new :co2 => 8_454_234, :cost => 712_943
    entries = [
      FuelEntry.new(:value => 1453, :co2 => 8454, :cost => 712, :unit => "kWh", :drill => "fuel=electricity"),
      FuelEntry.new(:value => 1453, :co2 => 8454, :cost => 712, :unit => "L", :drill => "fuel=petrol"),
      FuelEntry.new(:value => 1453, :co2 => 8454, :cost => 712, :unit => "kg", :drill => "fuel=fuel+oil"),
      FuelEntry.new(:drill => "fuel=naphtha")
    ]
    pdf = Pdf::Report.new.generate "Rock Band", "2009-10-13", "2009-10-21", 53, total, entries
    pdf.render_file "crc.pdf"
  end

end
