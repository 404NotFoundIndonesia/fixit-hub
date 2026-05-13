class RegistrationsController < Devise::RegistrationsController
  protected

  def sign_up_params
    # Strip role from public signup — all self-registrations are customers
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
  end

  def after_sign_up_path_for(resource)
    authenticated_root_path
  end
end
