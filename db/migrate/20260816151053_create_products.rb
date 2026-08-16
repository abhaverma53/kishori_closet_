class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :sku, null: false
      t.references :category, null: false, foreign_key: true
      t.string :color
      t.string :fabric
      t.boolean :active, null: false, default: true
      t.boolean :new_arrival, null: false, default: false
      t.boolean :best_seller, null: false, default: false

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
    add_index :products, :active
    add_index :products, :new_arrival
    add_index :products, :best_seller
  end
end
