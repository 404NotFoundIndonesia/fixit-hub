class ApplicationController < ActionController::Base
  include Authorizable

  protect_from_forgery with: :exception
end
