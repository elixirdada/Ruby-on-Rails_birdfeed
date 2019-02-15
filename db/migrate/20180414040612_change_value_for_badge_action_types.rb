class ChangeValueForBadgeActionTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :badge_points_weights, :required_count, :integer
    add_column :badge_points_weights, :condition, :string
    add_column :badge_points_weights, :active, :boolean, default: false
  end
end
