class CreateFuelEntries < ActiveRecord::Migration
  def self.up
    create_table :fuel_entries do |t|
      t.column :profile_id, :string, :limit => 32
      t.column :drill, :string, :limit => 255
      t.column :profile_item_id, :string, :limit => 32
      t.column :value, :integer
      t.column :unit, :string, :limit => 32
      t.column :co2, :float 
      t.column :cost, :float
      t.timestamps
      
      t.add_index :profile_id
    end
  end

  def self.down
    drop_table :fuel_entries
  end
end
