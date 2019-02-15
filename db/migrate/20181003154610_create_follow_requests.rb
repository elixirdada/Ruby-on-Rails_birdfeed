class CreateFollowRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :follow_requests do |t|
      t.integer :user_id
      t.string :followable_type
      t.integer :followable_id
      t.boolean :show_notify, default: true

      t.timestamps
    end

    remove_column :follows, :active, :boolean, default: false
  end
end
