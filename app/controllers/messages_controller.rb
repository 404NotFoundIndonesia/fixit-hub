class MessagesController < ApplicationController
  before_action :set_service_request
  before_action :authorize_participant!

  def create
    @message = @service_request.messages.build(body: params.dig(:message, :body))
    @message.sender = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to fallback_path, notice: "Message sent." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_message_form",
            partial: "messages/form",
            locals: { service_request: @service_request, message: @message }
          )
        end
        format.html { redirect_to fallback_path, alert: @message.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_service_request
    @service_request = ServiceRequest.find(params[:service_request_id])
  rescue ActiveRecord::RecordNotFound
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end

  def authorize_participant!
    is_customer   = current_user == @service_request.customer
    is_technician = @service_request.technician.present? &&
                    current_user == @service_request.technician

    return if is_customer || is_technician

    render file: Rails.root.join("public/403.html"), status: :forbidden, layout: false
  end

  def fallback_path
    if current_user.customer?
      customer_service_request_path(@service_request)
    elsif current_user.technician?
      technician_service_request_path(@service_request)
    else
      root_path
    end
  end
end
