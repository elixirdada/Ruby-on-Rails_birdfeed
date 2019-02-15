class AddAddressToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :city, :address_city
    add_column :users, :address_zip, :string
    add_column :users, :address_street, :string
    add_column :users, :address_street_number, :string
    add_column :users, :address_quarter, :string
    add_column :users, :address_state, :string
    add_column :users, :address_country, :string
  end
end
