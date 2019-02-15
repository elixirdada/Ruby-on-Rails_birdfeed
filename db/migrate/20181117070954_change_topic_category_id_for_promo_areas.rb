class ChangeTopicCategoryIdForPromoAreas < ActiveRecord::Migration[5.1]
  def change
    remove_column :promo_areas, :topic_category_id, :integer
    add_column    :promo_areas, :topic_category_ids, :string, array: true, default: []
  end
end
