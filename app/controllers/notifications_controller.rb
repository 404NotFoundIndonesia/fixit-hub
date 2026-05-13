class NotificationsController < ApplicationController
  before_action :ensure_not_admin!

  def index
    @notifications = current_user.notifications.recent.limit(50)
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_read!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end

  private

  def ensure_not_admin!
    render file: Rails.root.join("public/403.html"), status: :forbidden, layout: false if current_user.admin?
  end
end
