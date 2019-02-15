class AddImageToArtistInfos < ActiveRecord::Migration[5.1]
  def change
    add_column :artist_infos, :image, :string
  end
end
