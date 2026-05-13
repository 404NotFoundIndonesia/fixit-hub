module Admin
  class UsersController < BaseController
    before_action :set_technician, only: [:edit, :update]

    def index
      @technicians = User.technician.order(created_at: :desc)
    end

    def new
      @technician = User.new
    end

    def create
      @technician = User.new(technician_create_params)
      @technician.role = :technician

      if @technician.save
        redirect_to admin_users_path, notice: "Technician #{@technician.email} created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @technician.update(technician_update_params)
        redirect_to admin_users_path, notice: "Technician #{@technician.email} updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_technician
      @technician = User.technician.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end

    def technician_create_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def technician_update_params
      p = params.require(:user).permit(:email, :password, :password_confirmation, :active)
      # Skip password update when left blank
      p.delete(:password) if p[:password].blank?
      p.delete(:password_confirmation) if p[:password_confirmation].blank?
      p
    end
  end
end
