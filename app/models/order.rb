class Order < ApplicationRecord
  STATUSES = [
    "pending",
    "confirmed",
    "processing",
    "packed",
    "shipped",
    "out_for_delivery",
    "delivered",
    "cancelled",
    "returned"
  ].freeze

  belongs_to :user
  has_many :order_items, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :customer_name, :customer_phone, :address_line_1, :city, :state, :pincode, presence: true
  validates :order_status, inclusion: { in: STATUSES }
  validates :payment_method, inclusion: { in: %w[UPI COD] }
  validates :pincode, format: { with: /\A\d{6}\z/, message: "must be a 6-digit PIN code" }

  before_validation :assign_order_number, on: :create

  scope :newest, -> { order(created_at: :desc) }
  scope :pending, -> { where(order_status: "pending") }
  scope :delivered, -> { where(order_status: "delivered") }

  def status_label
    order_status.to_s.titleize
  end

  def payment_label
    payment_method == "UPI" ? "UPI" : payment_method.titleize
  end

  def unpaid?
    payment_status == "pending"
  end

  def paid?
    payment_status == "paid"
  end

  def upi_pay_url
    amount = format("%.2f", total.to_f)
    "upi://pay?pa=#{KishoriCloset::UPI_ID}&pn=#{ERB::Util.url_encode(KishoriCloset::UPI_NAME)}&am=#{amount}&cu=INR&tn=#{order_number}"
  end

  def confirm_upi_payment!
    return false unless unpaid?

    update!(payment_status: "paid", order_status: "confirmed")
    send_order_emails
    true
  end

  def delivery_address
    [address_line_1, address_line_2, city, state, pincode].compact_blank.join(", ")
  end

  def cancellable?
    %w[pending confirmed].include?(order_status)
  end

  private

  def send_order_emails
    order_items.load
    OrderMailer.customer_order(self).deliver_now
    OrderMailer.admin_order(self).deliver_now
  rescue StandardError => e
    Rails.logger.error("Order email failed for #{order_number}: #{e.class} #{e.message}")
  end

  def assign_order_number
    return if order_number.present?

    next_id = (Order.maximum(:id) || 0) + 1
    self.order_number = format("ORD-%06d", next_id)
  end
end
