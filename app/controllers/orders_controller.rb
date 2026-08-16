class OrdersController < ApplicationController
  before_action :authenticate_customer!

  def index
    @orders = current_user.orders.includes(:order_items).newest
  end

  def show
    @order = current_user.orders.includes(:order_items).find(params[:id])
  end

  def confirmation
    @order = current_user.orders.find(params[:id])
  end
end
