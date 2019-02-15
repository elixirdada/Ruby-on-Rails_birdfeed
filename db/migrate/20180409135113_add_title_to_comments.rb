class AddTitleToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :title, :string
    remove_column :comments, :lft, :integer
    remove_column :comments, :rgt, :integer
  end
end
