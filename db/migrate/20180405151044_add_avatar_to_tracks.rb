class AddAvatarToTracks < ActiveRecord::Migration[5.1]
  def change
    add_column :tracks, :avatar, :string
  end
end
