module Admin
  class DashboardController < BaseController
    def index
      @product_count = Product.count
      @customer_count = User.customer.count
      @order_count = Order.count
      @pending_orders = Order.pending.count
      @delivered_orders = Order.delivered.count
      @recent_orders = Order.includes(:user).newest.limit(8)
    end
  end
end
