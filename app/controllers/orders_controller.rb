class OrdersController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_order, only: [:show, :confirmation, :pay, :confirm_payment]

  def index
    @orders = current_user.orders.includes(:order_items).newest
  end

  def show; end

  def confirmation
    redirect_to pay_order_path(@order) if @order.unpaid?
  end

  def pay
    redirect_to confirmation_order_path(@order) if @order.paid?
  end

  def confirm_payment
    redirect_to confirmation_order_path(@order) and return if @order.paid?

    if @order.claim_upi_payment!(params[:payment_reference])
      redirect_to pay_order_path(@order), notice: "Payment details submitted. Your order will be confirmed after Kishori Closet verifies the UPI payment."
    else
      flash.now[:alert] = @order.errors[:payment_reference].presence&.to_sentence || "Enter the UPI transaction ID from your payment app."
      render :pay, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = current_user.orders.includes(:order_items).find(params[:id])
  end
end
