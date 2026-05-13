module Admin
  class AnalyticsController < BaseController
    def index
      @date_from = parse_date(params[:date_from]) || 30.days.ago.to_date
      @date_to   = parse_date(params[:date_to])   || Date.today

      range = @date_from.beginning_of_day..@date_to.end_of_day

      # RPT-01: requests by status within date range
      @by_status = ServiceRequest.where(created_at: range).group(:status).count

      # RPT-02: technician performance (all-time)
      @technician_stats = technician_performance_stats

      # RPT-03: device trends by brand/model (all-time)
      @by_device = ServiceRequest.group(:device_brand, :device_model)
                                 .order(:device_brand, :device_model)
                                 .count
    end

    private

    def parse_date(value)
      Date.parse(value) if value.present?
    rescue ArgumentError
      nil
    end

    def technician_performance_stats
      User.technician.map do |tech|
        completed = ServiceRequest.completed.where(technician_id: tech.id).to_a
        timed     = completed.select { |sr| sr.assigned_at && sr.completed_at }
        avg_sec   = timed.any? ? timed.sum { |sr| sr.completed_at - sr.assigned_at } / timed.size : nil
        { technician: tech, completed_count: completed.size, avg_seconds: avg_sec }
      end
    end
  end
end
