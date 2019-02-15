class AddKindIdToBadgeActionTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :badge_action_types, :badge_kind_id, :integer
    add_column :badge_action_types, :points, :integer
    add_column :badge_action_types, :count_to_achieve, :integer, default: 1
  end
end
