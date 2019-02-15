class AddDefaultToPlaylists < ActiveRecord::Migration[5.1]
  def change
    add_column :playlists, :default, :boolean, default: false
  end
end
