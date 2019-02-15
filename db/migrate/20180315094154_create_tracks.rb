class CreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.string :title
      t.string :url
      t.integer :release_id
      t.string :artist
      t.integer :track_number
      t.string :genre
      t.string :isrc_code
      t.string :sample_uri
      t.string :waveform_image_uri

      t.timestamps
    end
  end
end
