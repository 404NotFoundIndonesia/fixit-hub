class ServiceRequestMailerPreview < ActionMailer::Preview
  def status_changed
    ServiceRequestMailer.status_changed(ServiceRequest.first)
  end

  def new_message
    ServiceRequestMailer.new_message(Message.first)
  end
end
