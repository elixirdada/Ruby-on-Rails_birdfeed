class CreateTopicCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :topic_categories do |t|
      t.string :title
      t.integer :prior, default: 0

      t.timestamps
    end
  end
end
