class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def empty?
    cart_items.empty?
  end

  def total_quantity
    cart_items.sum(:quantity)
  end

  def subtotal
    cart_items.sum { |item| item.line_total }
  end

  def shipping_fee
    Rails.application.config.shipping_fee
  end

  def total
    subtotal + shipping_fee
  end

  def clear!
    cart_items.destroy_all
  end
end
