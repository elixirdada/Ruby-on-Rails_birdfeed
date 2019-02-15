class RenameArtistIdForTracks < ActiveRecord::Migration[5.1]
  def change
    rename_column :tracks, :artist_id, :user_id
  end
end
