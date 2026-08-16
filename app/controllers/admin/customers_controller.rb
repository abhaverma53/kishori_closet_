module Admin
  class CustomersController < BaseController
    def index
      @customers = User.customer.includes(:orders).order(created_at: :desc)
      @customers = @customers.where("name ILIKE :q OR email ILIKE :q OR phone ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    end

    def show
      @customer = User.customer.find(params[:id])
      @orders = @customer.orders.newest
      @addresses = @customer.addresses
    end
  end
end
