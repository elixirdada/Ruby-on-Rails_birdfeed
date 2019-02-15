class AddIndexToFollows < ActiveRecord::Migration[5.1]
  def change
     add_index :follows, [:user_id, :followable_id, :followable_type], unique: true
  end
end
