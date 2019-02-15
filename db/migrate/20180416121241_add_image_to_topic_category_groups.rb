class AddImageToTopicCategoryGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :topic_category_groups, :image, :string
  end
end
