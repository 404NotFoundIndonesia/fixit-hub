require "test_helper"

class Technician::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "technician can access technician dashboard" do
    sign_in users(:technician)
    get technician_dashboard_path
    assert_response :success
  end

  test "admin cannot access technician dashboard" do
    sign_in users(:admin)
    get technician_dashboard_path
    assert_response :forbidden
  end

  test "customer cannot access technician dashboard" do
    sign_in users(:customer)
    get technician_dashboard_path
    assert_response :forbidden
  end

  test "unauthenticated request redirected to sign in" do
    get technician_dashboard_path
    assert_redirected_to new_user_session_path
  end
end
