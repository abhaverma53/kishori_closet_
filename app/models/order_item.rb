class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :product_name, :size, :sku, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :price, :total, numericality: { greater_than_or_equal_to: 0 }
end
