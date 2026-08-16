class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :product_variant

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :price, numericality: { greater_than: 0 }
  validates :product_variant_id, uniqueness: { scope: :cart_id }
  validate :quantity_within_stock

  def line_total
    price * quantity
  end

  def increment_quantity!(amount = 1)
    update_quantity!(quantity + amount)
  end

  def decrement_quantity!(amount = 1)
    new_qty = quantity - amount
    if new_qty <= 0
      destroy!
    else
      update_quantity!(new_qty)
    end
  end

  def update_quantity!(new_quantity)
    if new_quantity > product_variant.stock_quantity
      errors.add(:quantity, "Only #{product_variant.stock_quantity} items available.")
      raise ActiveRecord::RecordInvalid, self
    end

    update!(quantity: new_quantity)
  end

  private

  def quantity_within_stock
    return if product_variant.blank? || quantity.blank?

    if quantity > product_variant.stock_quantity
      errors.add(:quantity, "Only #{product_variant.stock_quantity} items available.")
    end
  end
end
