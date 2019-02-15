class CreatePromocodes < ActiveRecord::Migration[5.1]
  def change
    create_table :promocodes do |t|
      t.string :slug
      t.integer :promo_type
      t.string :value
      t.integer :applied_to
      t.datetime :apply_date

      t.timestamps
    end

    add_index :promocodes, :slug, unique: true
  end
end
