require "test_helper"

class Technician::ServiceRequestsControllerTest < ActionDispatch::IntegrationTest
  # ── index ────────────────────────────────────────────────────────────────────

  test "technician sees only own assigned requests" do
    sign_in users(:technician)
    get technician_service_requests_path
    assert_response :success
  end

  test "customer blocked from technician index" do
    sign_in users(:customer)
    get technician_service_requests_path
    assert_response :forbidden
  end

  test "admin blocked from technician index" do
    sign_in users(:admin)
    get technician_service_requests_path
    assert_response :forbidden
  end

  # ── show ─────────────────────────────────────────────────────────────────────

  test "technician can view assigned request" do
    sign_in users(:technician)
    get technician_service_request_path(service_requests(:assigned_request))
    assert_response :success
  end

  test "technician cannot view request assigned to another technician" do
    other_tech = User.create!(email: "other_tech@example.com", password: "password123", role: :technician)
    sign_in other_tech
    get technician_service_request_path(service_requests(:assigned_request))
    assert_response :not_found
  end

  # ── update_status ─────────────────────────────────────────────────────────

  test "valid transition succeeds" do
    sign_in users(:technician)
    patch update_status_technician_service_request_path(service_requests(:assigned_request)),
          params: { status: "in_diagnosis" }
    assert_equal "in_diagnosis", service_requests(:assigned_request).reload.status
    assert_redirected_to technician_service_request_path(service_requests(:assigned_request))
  end

  test "invalid transition is rejected" do
    sign_in users(:technician)
    patch update_status_technician_service_request_path(service_requests(:assigned_request)),
          params: { status: "completed" }
    assert_equal "assigned", service_requests(:assigned_request).reload.status
    assert_redirected_to technician_service_request_path(service_requests(:assigned_request))
    assert_not_nil flash[:alert]
  end

  test "completing without a completion note is rejected" do
    sr = service_requests(:in_diagnosis_request)
    sr.update_column(:status, ServiceRequest.statuses[:in_repair])

    sign_in users(:technician)
    patch update_status_technician_service_request_path(sr), params: { status: "completed" }
    assert_equal "in_repair", sr.reload.status
    assert_not_nil flash[:alert]
  end

  test "completing with a completion note succeeds" do
    sr = service_requests(:in_diagnosis_request)
    sr.update_column(:status, ServiceRequest.statuses[:in_repair])
    sr.service_notes.create!(technician: users(:technician), note_type: :completion, body: "Done")

    sign_in users(:technician)
    patch update_status_technician_service_request_path(sr), params: { status: "completed" }
    assert_equal "completed", sr.reload.status
  end

  test "customer blocked from update_status" do
    sign_in users(:customer)
    patch update_status_technician_service_request_path(service_requests(:assigned_request)),
          params: { status: "in_diagnosis" }
    assert_response :forbidden
  end
end
