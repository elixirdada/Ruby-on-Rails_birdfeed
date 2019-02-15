class ChangeColumnTypeLyrics < ActiveRecord::Migration[5.1]
  def up
    change_column :track_infos, :lyrics, :text
  end
  def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :track_infos, :lyrics, :string
end

end
