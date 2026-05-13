module Technician
  class ServiceRequestsController < BaseController
    before_action :set_service_request, only: [:show, :update_status]

    def index
      priority_order = ServiceRequest::STATUS_PRIORITY
      @service_requests = current_user.assigned_service_requests
        .order(
          Arel.sql(
            "CASE status " +
            priority_order.each_with_index.map { |s, i| "WHEN #{ServiceRequest.statuses[s]} THEN #{i}" }.join(" ") +
            " END"
          ),
          updated_at: :asc
        )
    end

    def show
      @service_note = ServiceNote.new
    end

    def update_status
      new_status = params[:status].to_s

      unless @service_request.can_transition_to?(new_status)
        return redirect_to technician_service_request_path(@service_request),
                           alert: "Invalid status transition."
      end

      if new_status == "completed" && @service_request.service_notes.completion.none?
        return redirect_to technician_service_request_path(@service_request),
                           alert: "Add a completion note before marking as completed."
      end

      @service_request.update!(status: new_status)
      redirect_to technician_service_request_path(@service_request),
                  notice: "Status updated to #{new_status.humanize}."
    end

    private

    def set_service_request
      @service_request = current_user.assigned_service_requests.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end
end
