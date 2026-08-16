class CheckoutsController < ApplicationController
  before_action :authenticate_customer!
  before_action :ensure_cart_present

  def show
    @cart_items = current_cart.cart_items.includes(:product, :product_variant)
    @address = current_user.addresses.order(updated_at: :desc).first
  end

  def create
    checkout = Checkout.new(user: current_user, params: checkout_params)
    if checkout.place_order
      redirect_to confirmation_order_path(checkout.order), notice: "Order placed successfully."
    else
      @cart_items = current_cart.cart_items.includes(:product, :product_variant)
      @address = current_user.addresses.order(updated_at: :desc).first
      flash.now[:alert] = checkout.errors.to_sentence.presence || "Unable to place order. Please check the details."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def ensure_cart_present
    return unless current_cart.blank? || current_cart.empty?

    redirect_to cart_path, alert: "Your cart is empty."
  end

  def checkout_params
    params.require(:checkout).permit(
      :customer_name, :customer_phone, :address_line_1, :address_line_2,
      :city, :state, :pincode, :save_address
    )
  end
end
