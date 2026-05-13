module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Devise/Warden stores the authenticated user in the rack env
      if (user = env["warden"].user)
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end
