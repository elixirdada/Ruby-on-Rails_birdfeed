class AddShowcaseToAnnouncements < ActiveRecord::Migration[5.1]
  def change
    add_column :announcements, :showcase, :string
  end
end
