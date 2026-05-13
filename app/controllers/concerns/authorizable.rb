module Authorizable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def require_role(*roles)
    return if roles.map(&:to_s).include?(current_user.role)

    render file: Rails.root.join("public/403.html"), status: :forbidden, layout: false
  end

  def require_admin!
    require_role(:admin)
  end

  def require_technician!
    require_role(:technician)
  end

  def require_customer!
    require_role(:customer)
  end
end
