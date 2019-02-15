class AddArtistsToReleases < ActiveRecord::Migration[5.1]
  def change
    remove_column :tracks, :user_id, :integer
    remove_column :releases, :artist_id, :integer
    create_table :releases_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :release, index: true
    end
    add_index :likes, [:user_id, :likeable_id, :likeable_type], unique: true
  end
end
