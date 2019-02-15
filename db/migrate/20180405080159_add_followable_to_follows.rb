class AddFollowableToFollows < ActiveRecord::Migration[5.1]
  def change
    add_column :follows, :followable_type, :string
    rename_column :follows, :target_id, :followable_id
  end
end
