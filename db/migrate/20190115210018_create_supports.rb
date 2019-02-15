class CreateSupports < ActiveRecord::Migration[5.1]
  def change
    create_table :supports do |t|
      t.string :email
      t.string :topic
      t.text :message

      t.timestamps
    end
  end
end
