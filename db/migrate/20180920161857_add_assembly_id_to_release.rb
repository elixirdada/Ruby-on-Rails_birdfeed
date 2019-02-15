class AddAssemblyIdToRelease < ActiveRecord::Migration[5.1]
  def change
    add_column :releases, :assembly_id, :string
    add_column :releases, :assembly_complete, :boolean
    add_column :track_files, :url_string, :string
  end
end
