class AddUserToBillingOrderHistories < ActiveRecord::Migration[5.1]
  def change
    add_reference :billing_order_histories, :user, foreign_key: true
  end
end
