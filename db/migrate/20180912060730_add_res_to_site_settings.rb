class AddResToSiteSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :site_settings, :res, :string
  end
end
