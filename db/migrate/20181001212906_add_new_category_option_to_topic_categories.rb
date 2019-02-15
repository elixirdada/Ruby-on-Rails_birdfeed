class AddNewCategoryOptionToTopicCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :topic_categories, :new_category_option, :boolean, default: false
  end
end
