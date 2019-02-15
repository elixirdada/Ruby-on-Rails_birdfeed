class AddSampleUrlsToTracks < ActiveRecord::Migration[5.1]
  def change
    rename_column :tracks, :sample_uri, :sample_mp3_uri
    add_column :tracks, :sample_ogg_uri, :string
  end
end
