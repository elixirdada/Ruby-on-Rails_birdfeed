class RenameImageurlForReleases < ActiveRecord::Migration[5.1]
  def change
    rename_column :releases, :image_url, :avatar
  end
end
