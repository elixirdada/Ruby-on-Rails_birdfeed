class CreateReleasesRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :releases_roles do |t|
      t.integer :release_id
      t.integer :role_id

      t.timestamps
    end
  end
end
