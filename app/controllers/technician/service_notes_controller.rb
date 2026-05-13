module Technician
  class ServiceNotesController < BaseController
    before_action :set_service_request

    def create
      @service_note = @service_request.service_notes.build(service_note_params)
      @service_note.technician = current_user

      if @service_note.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to technician_service_request_path(@service_request), notice: "Note added." }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "new_service_note_form",
              partial: "technician/service_notes/form",
              locals: { service_request: @service_request, service_note: @service_note }
            )
          end
          format.html { redirect_to technician_service_request_path(@service_request), alert: "Note could not be saved." }
        end
      end
    end

    private

    def set_service_request
      @service_request = current_user.assigned_service_requests.find(params[:service_request_id])
    rescue ActiveRecord::RecordNotFound
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end

    def service_note_params
      params.require(:service_note).permit(:body, :note_type)
    end
  end
end
