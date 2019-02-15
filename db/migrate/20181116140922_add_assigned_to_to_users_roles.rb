class AddAssignedToToUsersRoles < ActiveRecord::Migration[5.1]
  def change
    add_column :users_roles, :id, :primary_key
    add_column :users_roles, :assigned_to, :integer

    add_column :users_roles, :created_at, :datetime, null: false, default: DateTime.now
    add_column :users_roles, :updated_at, :datetime, null: false, default: DateTime.now
    add_index :users_roles, :assigned_to
  end
end
