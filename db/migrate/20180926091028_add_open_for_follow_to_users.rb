class AddOpenForFollowToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :open_for_follow, :boolean, default: false
  end
end
