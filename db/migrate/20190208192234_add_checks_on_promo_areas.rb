class AddChecksOnPromoAreas < ActiveRecord::Migration[5.1]
  def change
    add_column :promo_areas, :show_on_releases, :boolean, default: false
    add_column :promo_areas, :show_on_user_profile, :boolean, default: false
  end
end
