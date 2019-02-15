class ChangeDownloadCreditsForUsers < ActiveRecord::Migration[5.1]
  def up
   change_column :users, :download_credits, :integer, default: 0
  end

  def down
   change_column :users, :download_credits, :integer, default: 30
  end
end
