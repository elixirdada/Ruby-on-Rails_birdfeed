class CreateVideos < ActiveRecord::Migration[5.1]
  def change
    create_table :videos do |t|
      t.integer :user_id
      t.string :title
      t.string :video_link

      t.timestamps
    end

    remove_column :artist_infos, :video, :string
  end
end
