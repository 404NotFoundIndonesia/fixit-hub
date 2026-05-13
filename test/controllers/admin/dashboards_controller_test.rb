require "test_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "admin can access admin dashboard" do
    sign_in users(:admin)
    get admin_dashboard_path
    assert_response :success
  end

  test "technician cannot access admin dashboard" do
    sign_in users(:technician)
    get admin_dashboard_path
    assert_response :forbidden
  end

  test "customer cannot access admin dashboard" do
    sign_in users(:customer)
    get admin_dashboard_path
    assert_response :forbidden
  end

  test "unauthenticated request redirected to sign in" do
    get admin_dashboard_path
    assert_redirected_to new_user_session_path
  end
end
