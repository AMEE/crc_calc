class CreateClientDetails < ActiveRecord::Migration
  def self.up
    create_table :client_details do |t|
      t.column :guid, :string
      t.column :profile_id, :string, :limit => 32
      t.column :hhm_reading, :boolean, :default => true
      t.timestamps
      
      t.add_index :guid
      t.add_index :profile_id
    end
  end

  def self.down
    drop_table :client_details
  end
end
