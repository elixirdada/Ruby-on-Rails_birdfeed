class AddListenedCountToTracks < ActiveRecord::Migration[5.1]
  def change
    add_column :tracks, :listened_count, :integer, default: 0
  end
end
