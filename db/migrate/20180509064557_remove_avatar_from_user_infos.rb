class RemoveAvatarFromUserInfos < ActiveRecord::Migration[5.1]
  def change
    remove_column :artist_infos, :avatar, :string
  end
end
