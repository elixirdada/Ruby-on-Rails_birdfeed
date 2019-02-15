class AddHeaderToUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :header, foreign_key: true, default: nil
  end

  def down
    remove_reference :users, :header
  end
end
