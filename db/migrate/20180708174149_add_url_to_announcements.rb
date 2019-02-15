class AddUrlToAnnouncements < ActiveRecord::Migration[5.1]
  def change
    add_column :announcements, :url, :string
  end
end
