class CreateFeedImages < ActiveRecord::Migration[5.1]
  def change
    create_table :feed_images do |t|
      t.integer :feedable_id
      t.string :feedable_type
      t.string :image

      t.timestamps
    end
  end
end
