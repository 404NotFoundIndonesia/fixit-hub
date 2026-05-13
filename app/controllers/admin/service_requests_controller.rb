module Admin
  class ServiceRequestsController < BaseController
    before_action :set_service_request, only: [:show, :assign]

    def index
      @service_requests = ServiceRequest.includes(:customer, :technician)

      @service_requests = @service_requests.where(status: params[:status]) if params[:status].present?

      if params[:date_from].present?
        @service_requests = @service_requests.where("created_at >= ?", params[:date_from].to_date.beginning_of_day)
      end
      if params[:date_to].present?
        @service_requests = @service_requests.where("created_at <= ?", params[:date_to].to_date.end_of_day)
      end

      @service_requests = @service_requests.order(created_at: :desc)
    end

    def show
      @technicians = User.technician.where(active: true)
                         .left_joins(:assigned_service_requests)
                         .where(service_requests: { status: [nil, *ServiceRequest.statuses.values_at("assigned", "in_diagnosis", "in_repair")] })
                         .group("users.id")
                         .order("COUNT(service_requests.id) ASC")
    end

    def assign
      technician = User.technician.where(active: true).find_by(id: params[:technician_id])

      unless technician
        return redirect_to admin_service_request_path(@service_request),
                           alert: "Technician not found or is deactivated."
      end

      was_submitted = @service_request.submitted?
      @service_request.technician = technician
      @service_request.status = :assigned if was_submitted

      if @service_request.save
        redirect_to admin_service_request_path(@service_request),
                    notice: "Request assigned to #{technician.email}."
      else
        @technicians = User.technician.where(active: true)
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_service_request
      @service_request = ServiceRequest.find(params[:id])
    end
  end
end
