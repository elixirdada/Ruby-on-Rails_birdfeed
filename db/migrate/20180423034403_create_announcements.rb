class CreateAnnouncements < ActiveRecord::Migration[5.1]
  def change
    create_table :announcements do |t|
      t.integer :user_id
      t.integer :release_id
      t.string :title
      t.text :text
      t.string :avatar

      t.timestamps
    end
  end
end
