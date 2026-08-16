class Address < ApplicationRecord
  belongs_to :user

  validates :full_name, :phone, :address_line_1, :city, :state, :pincode, presence: true
  validates :pincode, format: { with: /\A\d{6}\z/, message: "must be a 6-digit PIN code" }
  validates :phone, format: { with: /\A[0-9+\-\s]{8,15}\z/ }

  def full_address
    [address_line_1, address_line_2, city, state, pincode].compact_blank.join(", ")
  end
end
