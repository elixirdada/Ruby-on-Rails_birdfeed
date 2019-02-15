class AddCounts < ActiveRecord::Migration[5.1]
  def change
    add_column :artist_infos, :followers_count, :integer, default: 0
    add_column :artist_infos, :tracks_count, :integer, default: 0
    add_column :comments, :likes_count, :integer, default: 0
    add_column :comments, :comments_count, :integer, default: 0
    add_column :comments, :shares_count, :integer, default: 0
    add_column :videos, :comments_count, :integer, default: 0
    add_column :videos, :shares_count, :integer, default: 0
  end
end
