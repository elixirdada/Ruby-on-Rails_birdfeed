class ChangeAddressForUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :shipping_address, :string
    remove_column :users, :address_quarter, :string
    rename_column :users, :address_street, :address_line_1
    rename_column :users, :address_street_number, :address_line_2
  end
end
