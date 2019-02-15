class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :text
      t.string :image_url
      t.datetime :published_at

      t.timestamps
    end
  end
end
