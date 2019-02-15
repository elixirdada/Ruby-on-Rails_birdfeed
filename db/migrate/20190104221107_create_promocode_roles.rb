class CreatePromocodeRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :promocode_roles do |t|
      t.integer :promocode_id
      t.integer :role_id
      t.timestamps
    end
  end
end
