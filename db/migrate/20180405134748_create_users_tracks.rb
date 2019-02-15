class CreateUsersTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks_users do |t|
      t.belongs_to :user, index: true
      t.belongs_to :track, index: true
    end

    add_index :tracks_users, [:user_id, :track_id], unique: true
  end
end
