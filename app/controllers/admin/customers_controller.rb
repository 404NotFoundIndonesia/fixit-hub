module Admin
  class CustomersController < BaseController
    before_action :set_customer, only: [:show]

    def index
      @customers = User.customer.order(created_at: :desc)
    end

    def show
      @service_requests = @customer.service_requests.order(created_at: :desc)
    end

    private

    def set_customer
      @customer = User.customer.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end
end
