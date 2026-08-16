class AddressesController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_address, only: [:edit, :update, :destroy]

  def index
    @addresses = current_user.addresses.order(created_at: :desc)
  end

  def new
    @address = current_user.addresses.build(full_name: current_user.name, phone: current_user.phone)
  end

  def create
    @address = current_user.addresses.build(address_params)
    if @address.save
      redirect_to addresses_path, notice: "Address saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: "Address updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to addresses_path, notice: "Address removed."
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:full_name, :phone, :address_line_1, :address_line_2, :city, :state, :pincode)
  end
end
