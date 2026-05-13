require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated request redirects to sign in" do
    get authenticated_root_path
    assert_redirected_to new_user_session_path
  end

  test "admin redirected to admin dashboard" do
    sign_in users(:admin)
    get authenticated_root_path
    assert_redirected_to admin_dashboard_path
  end

  test "technician redirected to technician dashboard" do
    sign_in users(:technician)
    get authenticated_root_path
    assert_redirected_to technician_dashboard_path
  end

  test "customer redirected to customer dashboard" do
    sign_in users(:customer)
    get authenticated_root_path
    assert_redirected_to customer_dashboard_path
  end
end
