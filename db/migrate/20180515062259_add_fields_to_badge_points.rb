class AddFieldsToBadgePoints < ActiveRecord::Migration[5.1]
  def change
    add_column :badge_points, :accumulated_count, :integer
    add_column :badge_points, :badge_action_type_id, :integer
  end
end
