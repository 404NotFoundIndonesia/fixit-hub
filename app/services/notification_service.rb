class NotificationService
  def self.notify_status_change(service_request)
    service_request.notifications.create!(
      user:    service_request.customer,
      message: "Your service request ##{service_request.id} is now #{service_request.status.humanize}."
    )

    if service_request.status == "assigned" && service_request.technician.present?
      service_request.notifications.create!(
        user:    service_request.technician,
        message: "Service request ##{service_request.id} has been assigned to you."
      )
    end
  end
end
