module Customer
  class ServiceRequestsController < BaseController
    before_action :set_service_request, only: [:show]

    def index
      @service_requests = current_user.service_requests.order(created_at: :desc)
    end

    def show
    end

    def new
      @service_request = ServiceRequest.new
    end

    def create
      @service_request = current_user.service_requests.build(service_request_params)
      @service_request.status = :submitted

      if @service_request.save
        redirect_to customer_service_request_path(@service_request),
                    notice: "Service request submitted successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_service_request
      @service_request = current_user.service_requests.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end

    def service_request_params
      params.require(:service_request).permit(
        :device_brand, :device_model, :serial_number,
        :issue_description, :contact_info
      )
    end
  end
end
