class AddArtistToReleases < ActiveRecord::Migration[5.1]
  def change
    add_column :releases, :artist, :string
  end
end
