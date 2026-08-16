class CreateProductVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :size, null: false
      t.string :sku, null: false
      t.integer :stock_quantity, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :product_variants, :sku, unique: true
    add_index :product_variants, [:product_id, :size], unique: true
  end
end
