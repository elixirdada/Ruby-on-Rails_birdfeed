class RenameTracksForPlaylists < ActiveRecord::Migration[5.1]
  def change
    rename_column :playlists, :tracks, :tracks_ids
  end
end
