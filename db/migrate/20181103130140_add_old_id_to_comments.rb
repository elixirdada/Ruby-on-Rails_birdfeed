class AddOldIdToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :old_id, :integer
    add_column :posts, :old_id, :integer
  end
end
