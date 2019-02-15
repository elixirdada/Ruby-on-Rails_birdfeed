class CreatePlaylists < ActiveRecord::Migration[5.1]
  def change
    create_table :playlists do |t|
      t.integer :user_id
      t.string :tracks
      t.string :current_track

      t.timestamps
    end
  end
end
