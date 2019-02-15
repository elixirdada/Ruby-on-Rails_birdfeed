class AddShowcaseToReleases < ActiveRecord::Migration[5.1]
  def change
    add_column :releases, :showcase, :string
  end
end
