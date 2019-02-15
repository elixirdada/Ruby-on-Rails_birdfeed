class CreateCancellations < ActiveRecord::Migration[5.1]
  def change
    create_table :cancellations do |t|
      t.string :why_cancel_account
      t.string :your_thoughts

      t.timestamps
    end
  end
end
