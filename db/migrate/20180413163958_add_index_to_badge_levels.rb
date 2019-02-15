class AddIndexToBadgeLevels < ActiveRecord::Migration[5.1]
  def change
    add_index :badge_levels, [:badge_id, :user_id], unique: true
  end
end
