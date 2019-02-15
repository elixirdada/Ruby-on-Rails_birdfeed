class CreatePromocodesUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :promocodes_users do |t|
      t.integer :promocode_id
      t.integer :user_id

      t.timestamps
    end

    remove_column :promocodes, :applied_to, :integer
    rename_column :promocodes, :apply_date, :expiration_date

    add_index :promocodes_users, [:user_id, :promocode_id], unique: true
  end
end
