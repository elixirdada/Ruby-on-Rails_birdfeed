class AddGenreToArtistInfos < ActiveRecord::Migration[5.1]
  def change
    add_column :artist_infos, :genre, :string
  end
end
