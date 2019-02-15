class AddIndexToTracksUsers < ActiveRecord::Migration[5.1]
  def change
    add_index :releases_users, [:release_id, :user_id], unique: true
    add_index :tracks_users, [:track_id, :user_id], unique: true
  end
end
