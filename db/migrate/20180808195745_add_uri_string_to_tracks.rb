class AddUriStringToTracks < ActiveRecord::Migration[5.1]
  def change
    add_column :tracks, :uri_string, :string
  end
end
