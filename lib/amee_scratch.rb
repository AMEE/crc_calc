require 'rubygems'
gem 'Floppy-amee' 
require 'amee'

SERVER = "stage.amee.com"
USERNAME = "paulcarey"
PASSWORD = "3d21c90c"
CATEGORY = "/business/energy/stationaryCombustion/crc"
DRILL = "fuel=electricity "
PROFILE = "2F9777005C67"

amee = AMEE::Connection.new(SERVER, USERNAME, PASSWORD, :enable_debug => false)
uid = AMEE::Data::DrillDown.get(amee, "/data#{CATEGORY}/drill?#{DRILL}").data_item_uid

parameters = { 
  :energyUsed => '75',
  :energyUsedUnit => 'kWh',
}

# Store profile item
item = AMEE::Profile::Item.create_without_category(amee, "/profiles/#{PROFILE}#{CATEGORY}", uid, parameters)
piuid = item.uid

puts "Result is #{item.total_amount} #{item.total_amount_unit}"

item = AMEE::Profile::Item.update(amee, "/profiles/#{PROFILE}#{CATEGORY}/#{piuid}", parameters)
puts "Result is #{item.total_amount} #{item.total_amount_unit}"
