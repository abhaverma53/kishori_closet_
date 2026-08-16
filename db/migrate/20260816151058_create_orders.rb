class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :order_number, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false
      t.decimal :shipping_fee, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false
      t.string :payment_method, null: false, default: "COD"
      t.string :payment_status, null: false, default: "pending"
      t.string :order_status, null: false, default: "pending"
      t.string :customer_name, null: false
      t.string :customer_phone, null: false
      t.string :address_line_1, null: false
      t.string :address_line_2
      t.string :city, null: false
      t.string :state, null: false
      t.string :pincode, null: false

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :order_status
  end
end
