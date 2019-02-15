class ChangeArtistForReleases < ActiveRecord::Migration[5.1]
  def change
    remove_column :releases, :artist, :string
    add_column    :releases, :artist_id, :integer
  end
end
