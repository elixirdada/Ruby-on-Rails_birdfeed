class AddAccumulatedAtToBadgePoints < ActiveRecord::Migration[5.1]
  def change
    add_column :badge_points, :accumulated_at, :datetime
  end
end
