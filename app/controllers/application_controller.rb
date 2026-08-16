class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?

  helper_method :current_cart, :cart_count

  def current_cart
    return unless user_signed_in? && current_user.customer?

    current_user.cart || current_user.create_cart!
  end

  def cart_count
    current_cart&.total_quantity.to_i
  end

  protected

  def authenticate_customer!
    authenticate_user!
    return if current_user.customer?

    redirect_to root_path, alert: "Please sign in with a customer account."
  end

  def authenticate_admin!
    authenticate_user!
    return if current_user.admin?

    redirect_to root_path, alert: "You are not authorized to access the admin area."
  end

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
