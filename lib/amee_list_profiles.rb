require 'rubygems'
gem 'Floppy-amee' 
require 'amee'

SERVER = "stage.amee.com"
USERNAME = "paulcarey"
PASSWORD = "3d21c90c"

amee = AMEE::Connection.new SERVER, USERNAME, PASSWORD, :enable_debug => true
profiles = AMEE::Profile::Profile.list amee

profiles.each { |p| puts p.inspect }
