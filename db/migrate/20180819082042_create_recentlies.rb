class CreateRecentlies < ActiveRecord::Migration[5.1]
  def change
    create_table :recently_items do |t|
      t.integer :user_id
      t.integer :track_id

      t.timestamps
    end
  end
end
