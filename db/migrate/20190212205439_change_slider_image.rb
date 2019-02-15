class ChangeSliderImage < ActiveRecord::Migration[5.1]
  def change
    rename_column :slider_images, :image_url, :imageurl
  end
end
