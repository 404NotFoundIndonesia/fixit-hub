class ServiceRequestChannel < ApplicationCable::Channel
  def subscribed
    service_request = ServiceRequest.find_by(id: params[:id])

    if service_request && participant?(service_request)
      stream_from "service_request_#{service_request.id}_messages"
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end

  private

  def participant?(service_request)
    current_user.id == service_request.customer_id ||
      (service_request.technician_id.present? &&
       current_user.id == service_request.technician_id)
  end
end
