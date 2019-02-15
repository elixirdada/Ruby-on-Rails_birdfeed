class AddNotifiedToBadgeLevels < ActiveRecord::Migration[5.1]
  def change
    add_column :badge_levels, :notified, :boolean, default: false
  end
end
