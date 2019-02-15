class AddPageTaegetToSliderImages < ActiveRecord::Migration[5.1]
  def change
    add_column :slider_images, :image_url_target, :string, default: ""
  end
end
