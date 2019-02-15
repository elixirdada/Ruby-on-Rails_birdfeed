class AddDownloadCreditsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :download_credits, :integer, default: 30, null: false
  end
end
