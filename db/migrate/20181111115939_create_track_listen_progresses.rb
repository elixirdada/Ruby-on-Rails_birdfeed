class CreateTrackListenProgresses < ActiveRecord::Migration[5.1]
  def change
    create_table :track_listen_progresses do |t|
      t.belongs_to :user, index: true
      t.belongs_to :track, index: true
      t.integer :listen_progress, default: 0
      t.timestamps
    end
  end
end
