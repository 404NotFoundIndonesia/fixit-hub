module Customer
  class BaseController < ApplicationController
    before_action :require_customer!

    layout "customer"
  end
end
