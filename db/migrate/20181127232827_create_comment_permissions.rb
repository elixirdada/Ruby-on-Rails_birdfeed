class CreateCommentPermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :comment_permissions do |t|
      t.references :comment
      t.references :role
      t.timestamps
    end
  end
end
