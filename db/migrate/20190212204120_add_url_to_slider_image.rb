class AddUrlToSliderImage < ActiveRecord::Migration[5.1]
  def change
    add_column :slider_images, :image_url, :string, default: ""
  end
end
