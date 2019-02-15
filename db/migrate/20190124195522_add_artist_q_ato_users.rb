class AddArtistQAtoUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :artist_infos, :artist_q_a, :text
  end
end
