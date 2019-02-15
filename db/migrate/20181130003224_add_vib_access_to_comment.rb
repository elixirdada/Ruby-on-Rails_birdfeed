class AddVibAccessToComment < ActiveRecord::Migration[5.1]
  def change
    add_column  :comments, :vib_only, :boolean, default: false
  end
end
