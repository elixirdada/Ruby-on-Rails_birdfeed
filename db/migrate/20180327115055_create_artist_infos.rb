class CreateArtistInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :artist_infos do |t|
      t.string :avatar
      t.string :bio_short
      t.text :bio_long
      t.string :facebook
      t.string :twitter
      t.string :instagram
      t.string :video
      t.integer :artist_id

      t.timestamps
    end
  end
end
