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
    if @order.confirm_upi_payment!
      redirect_to confirmation_order_path(@order), notice: "Payment received. Your order is confirmed."
    else
      redirect_to confirmation_order_path(@order), notice: "This order is already paid."
    end
  end

  private

  def set_order
    @order = current_user.orders.includes(:order_items).find(params[:id])
  end
end
