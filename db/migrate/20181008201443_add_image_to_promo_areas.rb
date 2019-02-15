class AddImageToPromoAreas < ActiveRecord::Migration[5.1]
  def change
    add_column :promo_areas, :image, :string
  end
end
