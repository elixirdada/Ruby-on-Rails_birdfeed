class AddExtendedBadges < ActiveRecord::Migration[5.1]
  def change
    add_column :badges, :badge_kind_id, :integer
    add_column :badges, :message, :string

    remove_column :users, :points, :integer

    create_table :badge_points do |t|
      t.integer :user_id
      t.integer :badge_kind_id
      t.integer :value

      t.timestamps
    end

    create_table :badge_kinds do |t|
      t.string :name

      t.timestamps
    end

    create_table :badge_dependencies do |t|
      t.integer :badge_id
      t.integer :depended_badge_id

      t.timestamps
    end

    create_table :badge_points_weights do |t|
      t.integer :badge_id
      t.integer :badge_action_type_id
      t.integer :value
      t.integer :required_count

      t.timestamps
    end

    add_index :badge_points_weights, [:badge_id, :badge_action_type_id], unique: true

    create_table :badge_action_types do |t|
      t.string :name

      t.timestamps
    end

    rename_table :levels, :badge_levels
  end
end
