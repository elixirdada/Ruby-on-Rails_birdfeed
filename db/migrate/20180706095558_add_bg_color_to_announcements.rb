class AddBgColorToAnnouncements < ActiveRecord::Migration[5.1]
  def change
    add_column :announcements, :bg_color, :string, default: "#8a8b8b"
    add_column :announcements, :feed_title, :string
  end
end
