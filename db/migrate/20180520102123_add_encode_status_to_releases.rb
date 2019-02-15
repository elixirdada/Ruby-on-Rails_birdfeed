class AddEncodeStatusToReleases < ActiveRecord::Migration[5.1]
  def change
    add_column :releases, :encode_status, :integer
  end
end
