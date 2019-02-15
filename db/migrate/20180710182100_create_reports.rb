class CreateReports < ActiveRecord::Migration[5.1]
  def change
    create_table :reports do |t|
      t.string :reportable_type
      t.integer :reportable_id
      t.string :text
      t.integer :user_id
      t.string :ip_address
      t.string :comment
      t.boolean :closed, default: false

      t.timestamps
    end
  end
end
