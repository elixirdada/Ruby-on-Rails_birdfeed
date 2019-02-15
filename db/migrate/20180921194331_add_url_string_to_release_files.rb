class AddUrlStringToReleaseFiles < ActiveRecord::Migration[5.1]
  def change
    add_column :release_files, :url_string, :string
  end
end
