class ProductVariant < ApplicationRecord
  SIZES = %w[XS S M L XL XXL].freeze

  belongs_to :product
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :nullify

  before_validation :assign_sku

  validates :size, presence: true, inclusion: { in: SIZES }, uniqueness: { scope: :product_id }
  validates :sku, presence: true, uniqueness: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where("stock_quantity > 0") }

  def in_stock?
    active? && stock_quantity.positive?
  end

  def out_of_stock?
    !in_stock?
  end

  def stock_status
    return "Out of Stock" if stock_quantity <= 0
    return "Low Stock" if stock_quantity <= 3

    "In Stock"
  end

  private

  def assign_sku
    return if sku.present? || product&.sku.blank? || size.blank?

    self.sku = "#{product.sku}-#{size}"
  end
end
