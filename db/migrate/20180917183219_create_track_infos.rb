class CreateTrackInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :track_infos do |t|
      t.string :label_name
      t.string :catalog
      t.string :release_artist
      t.string :track_title
      t.string :track_artist
      t.string :release_name
      t.datetime :release_date
      t.string :mix_name
      t.string :remixer
      t.string :track_time
      t.string :barcode
      t.string :isrc
      t.string :genre
      t.string :release_written_by
      t.string :release_producer
      t.string :track_publisher
      t.string :track_written_by
      t.string :track_produced_by
      t.boolean :vocals_m
      t.boolean :vocals_f
      t.boolean :upbeat_drivind_energetic
      t.boolean :sad_moody_dark
      t.boolean :fun_playfull_quirky
      t.boolean :sentimental_love
      t.boolean :big_buildups_sweeps
      t.boolean :celebratory_party_vibe
      t.boolean :inspiring_uplifting
      t.boolean :chill_mellow
      t.string :lyrics

      t.timestamps
    end
    add_column :tracks, :track_info_id, :integer
  end
end
