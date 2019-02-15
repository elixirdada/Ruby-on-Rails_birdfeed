class RenameUrlFromTracks < ActiveRecord::Migration[5.1]
  def change
    rename_column :tracks, :url, :uri
  end
end
