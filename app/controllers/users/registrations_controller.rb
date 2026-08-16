class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  def create
    super do |user|
      user.customer! if user.persisted? && user.role.blank?
    end
  end

  protected

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone])
  end

  def sign_up_params
    super.merge(role: :customer)
  end
end
