class ServiceRequestMailer < ApplicationMailer
  def status_changed(service_request)
    @service_request = service_request
    @customer        = service_request.customer
    mail(
      to:      @customer.email,
      subject: "Service Request ##{service_request.id} — Status Update"
    )
  end

  def new_message(message)
    @message         = message
    @service_request = message.service_request
    @customer        = @service_request.customer
    mail(
      to:      @customer.email,
      subject: "New message on Service Request ##{@service_request.id}"
    )
  end
end
