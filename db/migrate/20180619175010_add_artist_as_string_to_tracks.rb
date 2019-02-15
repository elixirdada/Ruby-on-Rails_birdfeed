class AddArtistAsStringToTracks < ActiveRecord::Migration[5.1]
  def change
    add_column :releases, :artist_as_string, :boolean
    add_column :tracks, :artist_as_string, :boolean
  end
end
