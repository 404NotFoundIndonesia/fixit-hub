require "test_helper"

class Customer::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "customer can access customer dashboard" do
    sign_in users(:customer)
    get customer_dashboard_path
    assert_response :success
  end

  test "admin cannot access customer dashboard" do
    sign_in users(:admin)
    get customer_dashboard_path
    assert_response :forbidden
  end

  test "technician cannot access customer dashboard" do
    sign_in users(:technician)
    get customer_dashboard_path
    assert_response :forbidden
  end

  test "unauthenticated request redirected to sign in" do
    get customer_dashboard_path
    assert_redirected_to new_user_session_path
  end
end
