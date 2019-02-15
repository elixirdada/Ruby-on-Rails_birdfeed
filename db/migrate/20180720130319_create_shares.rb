class CreateShares < ActiveRecord::Migration[5.1]
  def change
    create_table :shares do |t|
      t.integer :user_id
      t.string :social
      t.integer :shareable_id
      t.string :shareable_type

      t.timestamps
    end
  end
end
