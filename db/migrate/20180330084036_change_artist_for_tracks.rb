class ChangeArtistForTracks < ActiveRecord::Migration[5.1]
  def change
    remove_column :tracks, :artist, :string
    add_column    :tracks, :artist_id, :integer
  end
end
