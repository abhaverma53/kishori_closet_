class Product < ApplicationRecord
  belongs_to :category
  has_many :product_variants, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error
  has_many_attached :images

  accepts_nested_attributes_for :product_variants

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :color, presence: true
  validates :fabric, presence: true

  before_validation :generate_slug

  scope :active, -> { where(active: true) }
  scope :new_arrivals, -> { active.where(new_arrival: true) }
  scope :best_sellers, -> { active.where(best_seller: true) }
  scope :newest, -> { order(created_at: :desc) }
  scope :price_low_to_high, -> { order(price: :asc) }
  scope :price_high_to_low, -> { order(price: :desc) }

  def to_param
    slug
  end

  def in_stock?
    product_variants.where(active: true).where("stock_quantity > 0").exists?
  end

  def total_stock
    product_variants.sum(:stock_quantity)
  end

  def main_image
    images.attached? ? images.first : nil
  end

  def available_sizes
    product_variants.where(active: true).order(:id)
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
