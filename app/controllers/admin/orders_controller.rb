module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [:show, :update]

    def index
      @orders = Order.includes(:user).newest
      if params[:q].present?
        q = "%#{params[:q]}%"
        @orders = @orders.where("order_number ILIKE :q OR customer_name ILIKE :q OR customer_phone ILIKE :q", q: q)
      end
      @orders = @orders.where(order_status: params[:status]) if params[:status].present?
    end

    def show; end

    def update
      if @order.update(order_status: params[:order][:order_status])
        redirect_to admin_order_path(@order), notice: "Order status updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_order
      @order = Order.includes(:order_items, :user).find(params[:id])
    end
  end
end
