class AddRepliesCount < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :replies_count, :integer, default: 0
    rename_column :comments, :comments_count, :replies_count
  end
end
