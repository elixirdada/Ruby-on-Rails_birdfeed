class CreateBillingOrderHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :billing_order_histories do |t|
      t.string :order_id
      t.date :transaction_date
      t.string :product
      t.float :amount

      t.timestamps
    end
  end
end
