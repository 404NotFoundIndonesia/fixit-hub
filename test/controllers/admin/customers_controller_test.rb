require "test_helper"

class Admin::CustomersControllerTest < ActionDispatch::IntegrationTest
  # ── index ────────────────────────────────────────────────────────────────────

  test "admin can list all customers" do
    sign_in users(:admin)
    get admin_customers_path
    assert_response :success
  end

  test "customer count row appears for each customer" do
    sign_in users(:admin)
    get admin_customers_path
    assert_select "tbody tr", count: User.customer.count
  end

  test "customer blocked from customer list" do
    sign_in users(:customer)
    get admin_customers_path
    assert_response :forbidden
  end

  test "technician blocked from customer list" do
    sign_in users(:technician)
    get admin_customers_path
    assert_response :forbidden
  end

  # ── show ─────────────────────────────────────────────────────────────────────

  test "admin can view customer profile" do
    sign_in users(:admin)
    get admin_customer_path(users(:customer))
    assert_response :success
  end

  test "show lists all service requests for that customer" do
    sign_in users(:admin)
    get admin_customer_path(users(:customer))
    expected_count = users(:customer).service_requests.count
    assert_select "tbody tr", count: expected_count
  end

  test "show returns 404 for non-customer user" do
    sign_in users(:admin)
    get admin_customer_path(users(:technician))
    assert_response :not_found
  end

  test "customer cannot view profile page" do
    sign_in users(:customer)
    get admin_customer_path(users(:customer))
    assert_response :forbidden
  end
end
