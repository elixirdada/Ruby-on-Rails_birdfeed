class CreatePromoAreas < ActiveRecord::Migration[5.1]
  def change
    create_table :promo_areas do |t|
      t.string :url

      t.timestamps
    end
  end
end
