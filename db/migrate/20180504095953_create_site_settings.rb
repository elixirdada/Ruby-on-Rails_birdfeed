class CreateSiteSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :site_settings do |t|
      t.string :ident
      t.string :val

      t.timestamps
    end
  end
end
