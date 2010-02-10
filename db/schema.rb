# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091016092159) do

  create_table "client_details", :force => true do |t|
    t.string   "guid"
    t.string   "profile_id",  :limit => 32
    t.boolean  "hhm_reading",               :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fuel_entries", :force => true do |t|
    t.string   "profile_id",      :limit => 32
    t.string   "drill"
    t.string   "profile_item_id", :limit => 32
    t.integer  "value"
    t.string   "unit",            :limit => 32
    t.float    "co2"
    t.float    "cost"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
