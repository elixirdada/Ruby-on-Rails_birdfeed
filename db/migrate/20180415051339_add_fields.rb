class AddFields < ActiveRecord::Migration[5.1]
  def change
    add_column :releases, :available_to_all, :boolean
    add_column :users, :subscription_started_at, :datetime
    rename_column :users, :subscribtion_type, :subscription_type
  end
end
