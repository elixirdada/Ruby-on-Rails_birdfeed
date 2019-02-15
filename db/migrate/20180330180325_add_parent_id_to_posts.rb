class AddParentIdToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :parent_id, :integer
  end
end
