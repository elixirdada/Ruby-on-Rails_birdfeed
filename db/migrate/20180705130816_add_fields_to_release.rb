class AddFieldsToRelease < ActiveRecord::Migration[5.1]
  def change
    add_column :releases, :release_type, :integer, default: 0
    add_column :releases, :buy_uri, :string
  end
end
