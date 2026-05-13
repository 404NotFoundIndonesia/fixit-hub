class DashboardsController < ApplicationController
  def show
    case current_user.role
    when "admin"      then redirect_to admin_dashboard_path
    when "technician" then redirect_to technician_dashboard_path
    when "customer"   then redirect_to customer_dashboard_path
    end
  end
end
