class CreateReleases < ActiveRecord::Migration[5.1]
  def change
    create_table :releases do |t|
      t.string :title
      t.string :artist
      t.string :catalog
      t.text :text
      t.string :image_url
      t.string :facebook_img
      t.datetime :published_at
      t.string :upc_code
      t.boolean :compilation
      t.datetime :release_date

      t.timestamps
    end
  end
end
