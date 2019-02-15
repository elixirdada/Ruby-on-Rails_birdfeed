class ChangeSubscriptionLengthForUsers < ActiveRecord::Migration[5.1]
  def up
    change_column :users, :subscription_length, :integer, default: 0, null: false
  end

  def down
    change_column :users, :subscription_length, :integer
  end
end
