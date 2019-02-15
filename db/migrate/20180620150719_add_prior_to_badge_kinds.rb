class AddPriorToBadgeKinds < ActiveRecord::Migration[5.1]
  def change
    add_column :badge_kinds, :prior, :integer, default: 0
  end
end
