class AddPublishedAtToAnnouncements < ActiveRecord::Migration[5.1]
  def change
    add_column :announcements, :published_at, :datetime
  end
end