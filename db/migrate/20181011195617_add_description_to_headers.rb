class AddDescriptionToHeaders < ActiveRecord::Migration[5.1]
  def change
    add_column :headers, :description, :string
  end
end
