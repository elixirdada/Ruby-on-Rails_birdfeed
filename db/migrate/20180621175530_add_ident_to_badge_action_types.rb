class AddIdentToBadgeActionTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :badge_kinds, :ident, :string
    add_column :badge_action_types, :ident, :string
  end
end
