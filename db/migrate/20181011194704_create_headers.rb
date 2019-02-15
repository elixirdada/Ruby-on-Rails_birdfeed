class CreateHeaders < ActiveRecord::Migration[5.1]
  def change
    create_table :headers do |t|
      t.string :url

      t.timestamps
    end
  end
end
