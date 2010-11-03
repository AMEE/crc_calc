class AddPersonalDataToClientDetails < ActiveRecord::Migration
  def self.up
    add_column :client_details, :name, :string
    add_column :client_details, :email, :string
    add_column :client_details, :org_name, :string
  end

  def self.down
    remove_column :client_details, :name
    remove_column :client_details, :email
    remove_column :client_details, :org_name
  end
end
