class AddFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :braintree_customer_id, :string
    add_column :users, :shipping_address, :string
    add_column :users, :birthdate, :datetime
    add_column :users, :gender, :integer
    add_column :users, :t_shirt_size, :string
    add_column :users, :subscribtion_type, :integer
  end
end
