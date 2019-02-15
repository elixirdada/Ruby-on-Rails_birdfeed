class RenameTextForPosts < ActiveRecord::Migration[5.1]
  def change
    rename_column :posts, :text, :body
    rename_column :topics, :text, :body
    add_column :posts, :likes_count, :integer
  end
end
