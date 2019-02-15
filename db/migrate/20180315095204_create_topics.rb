class CreateTopics < ActiveRecord::Migration[5.1]
  def change
    create_table :topics do |t|
      t.string :title
      t.text :text
      t.integer :user_id
      t.boolean :pinned
      t.boolean :locked

      t.timestamps
    end
  end
end
