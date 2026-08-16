class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      stored_location_for(resource) || root_path
    end
  end
end
