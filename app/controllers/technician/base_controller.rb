module Technician
  class BaseController < ApplicationController
    before_action :require_technician!

    layout "technician"
  end
end
