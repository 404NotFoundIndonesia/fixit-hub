require "test_helper"

class Admin::ServiceRequestsControllerTest < ActionDispatch::IntegrationTest
  # ── index ────────────────────────────────────────────────────────────────────

  test "admin sees all requests" do
    sign_in users(:admin)
    get admin_service_requests_path
    assert_response :success
  end

  test "status filter narrows results" do
    sign_in users(:admin)
    get admin_service_requests_path, params: { status: "submitted" }
    assert_response :success
    assert_select "tbody tr", count: ServiceRequest.submitted.count
  end

  test "customer blocked from admin queue" do
    sign_in users(:customer)
    get admin_service_requests_path
    assert_response :forbidden
  end

  test "technician blocked from admin queue" do
    sign_in users(:technician)
    get admin_service_requests_path
    assert_response :forbidden
  end

  # ── show ─────────────────────────────────────────────────────────────────────

  test "admin can view any request" do
    sign_in users(:admin)
    get admin_service_request_path(service_requests(:submitted_request))
    assert_response :success
  end

  # ── assign ───────────────────────────────────────────────────────────────────

  test "admin can assign submitted request to technician" do
    sign_in users(:admin)
    sr = service_requests(:submitted_request)
    patch assign_admin_service_request_path(sr),
          params: { technician_id: users(:technician).id }
    sr.reload
    assert_equal users(:technician).id, sr.technician_id
    assert_equal "assigned", sr.status
    assert_not_nil sr.assigned_at
  end

  test "reassigning in-progress request keeps current status" do
    sign_in users(:admin)
    sr = service_requests(:in_diagnosis_request)
    new_tech = User.create!(email: "new_tech@example.com", password: "password123", role: :technician)
    patch assign_admin_service_request_path(sr),
          params: { technician_id: new_tech.id }
    assert_equal "in_diagnosis", sr.reload.status
    assert_equal new_tech.id, sr.reload.technician_id
  end

  test "assigning to deactivated technician is rejected" do
    sign_in users(:admin)
    patch assign_admin_service_request_path(service_requests(:submitted_request)),
          params: { technician_id: users(:inactive_technician).id }
    assert_equal "submitted", service_requests(:submitted_request).reload.status
    assert_not_nil flash[:alert]
  end

  test "customer blocked from assign action" do
    sign_in users(:customer)
    patch assign_admin_service_request_path(service_requests(:submitted_request)),
          params: { technician_id: users(:technician).id }
    assert_response :forbidden
  end
end
