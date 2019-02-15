class AddAuthorToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :author, :string
    add_column :posts, :author, :string
  end
end
