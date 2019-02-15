class AddAvatarSizeToAnnouncements < ActiveRecord::Migration[5.1]
  def change
    add_column  :announcements, :avatar_size, :integer
  end
end
