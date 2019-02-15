class AddBraintreeFieldsToUsers < ActiveRecord::Migration[5.1]
  def self.up
    add_column :users, :braintree_subscription_id, :string
    add_column :users, :braintree_subscription_expires_at, :date
    add_column :users, :subscription_length, :integer
    change_column :users, :subscription_started_at, :date
    change_column :users, :subscription_type, :integer, default: 0
  end

  def self.down
    change_column :users, :subscription_type, :integer
    remove_column :users, :braintree_subscription_id, :string
    remove_column :users, :braintree_subscription_expires_at, :date
    remove_column :users, :subscription_length, :integer
    change_column :users, :subscription_started_at, :datetime
  end
end
