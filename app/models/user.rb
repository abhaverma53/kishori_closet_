class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  enum role: { customer: 0, admin: 1 }

  has_one :cart, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error

  validates :name, presence: true
  validates :phone, format: { with: /\A[0-9+\-\s]{8,15}\z/, allow_blank: true }

  after_create :create_customer_cart

  def cart_item_count
    cart&.total_quantity.to_i
  end

  private

  def create_customer_cart
    create_cart! if customer?
  end
end
