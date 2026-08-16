class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :product_variant, foreign_key: true
      t.string :product_name, null: false
      t.string :size, null: false
      t.string :sku, null: false
      t.integer :quantity, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :total, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
