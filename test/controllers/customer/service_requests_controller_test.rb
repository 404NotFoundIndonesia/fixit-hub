require "test_helper"

class Customer::ServiceRequestsControllerTest < ActionDispatch::IntegrationTest
  # ── index ────────────────────────────────────────────────────────────────────

  test "customer sees only own requests" do
    sign_in users(:customer)
    get customer_service_requests_path
    assert_response :success
  end

  test "unauthenticated redirected to sign in" do
    get customer_service_requests_path
    assert_redirected_to new_user_session_path
  end

  test "admin blocked from customer index" do
    sign_in users(:admin)
    get customer_service_requests_path
    assert_response :forbidden
  end

  test "technician blocked from customer index" do
    sign_in users(:technician)
    get customer_service_requests_path
    assert_response :forbidden
  end

  # ── show ─────────────────────────────────────────────────────────────────────

  test "customer can view own request" do
    sign_in users(:customer)
    get customer_service_request_path(service_requests(:submitted_request))
    assert_response :success
  end

  test "customer cannot view another customer's request" do
    other_customer = User.create!(email: "other@example.com", password: "password123", role: :customer)
    other_request  = other_customer.service_requests.create!(
      device_brand: "HP", device_model: "X", issue_description: "broken", contact_info: "x@x.com"
    )
    sign_in users(:customer)
    get customer_service_request_path(other_request)
    assert_response :not_found
  end

  # ── new/create ───────────────────────────────────────────────────────────────

  test "customer can access new request form" do
    sign_in users(:customer)
    get new_customer_service_request_path
    assert_response :success
  end

  test "valid POST creates request with submitted status" do
    sign_in users(:customer)
    assert_difference("ServiceRequest.count") do
      post customer_service_requests_path, params: {
        service_request: {
          device_brand:      "HP",
          device_model:      "EliteBook 840",
          issue_description: "Won't boot",
          contact_info:      "test@example.com"
        }
      }
    end
    assert_equal "submitted", ServiceRequest.last.status
    assert_equal users(:customer), ServiceRequest.last.customer
    assert_redirected_to customer_service_request_path(ServiceRequest.last)
  end

  test "invalid POST re-renders form" do
    sign_in users(:customer)
    assert_no_difference("ServiceRequest.count") do
      post customer_service_requests_path, params: {
        service_request: { device_brand: "", device_model: "", issue_description: "", contact_info: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "status and technician_id cannot be set via params" do
    sign_in users(:customer)
    post customer_service_requests_path, params: {
      service_request: {
        device_brand:      "HP",
        device_model:      "Spectre",
        issue_description: "Cracked screen",
        contact_info:      "x@x.com",
        status:            "completed",
        technician_id:     users(:technician).id
      }
    }
    sr = ServiceRequest.last
    assert_equal "submitted", sr.status
    assert_nil sr.technician_id
  end
end
