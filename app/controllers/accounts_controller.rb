class AccountsController < ApplicationController
  before_action :authenticate_customer!

  def show
    @orders = current_user.orders.newest.limit(5)
    @addresses = current_user.addresses.order(created_at: :desc)
  end

  def edit; end

  def update
    if current_user.update(account_params)
      redirect_to account_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(:name, :phone)
  end
end
