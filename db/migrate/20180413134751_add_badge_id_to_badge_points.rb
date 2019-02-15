class AddBadgeIdToBadgePoints < ActiveRecord::Migration[5.1]
  def change
    add_column :badge_points, :badge_id, :integer
  end
end
