class AddImageToTopicCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :topic_categories, :image, :string
  end
end
