class AddAdminIdToReleases < ActiveRecord::Migration[5.1]
  def change
    add_column :releases, :admin_id, :integer
    rename_column :announcements, :user_id, :admin_id
    add_column :announcements, :release_date, :datetime

  end
end
