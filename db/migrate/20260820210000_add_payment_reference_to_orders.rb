class AddPaymentReferenceToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :payment_reference, :string
  end
end
