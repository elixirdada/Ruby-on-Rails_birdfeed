class MergeUploaders < ActiveRecord::Migration[5.1]
  def change
    add_column :announcements, :image_uri, :string
    add_column :releases, :image_uri, :string
    add_column :users, :image_uri, :string
  end
end
