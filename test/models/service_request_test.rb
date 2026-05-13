require "test_helper"

class ServiceRequestTest < ActiveSupport::TestCase
  # ── Validity ────────────────────────────────────────────────────────────────

  test "valid service request saves" do
    sr = ServiceRequest.new(
      customer:          users(:customer),
      device_brand:      "HP",
      device_model:      "Pavilion 15",
      issue_description: "Screen not working",
      contact_info:      "test@example.com",
      status:            :submitted
    )
    assert sr.valid?
  end

  test "missing device_brand is invalid" do
    sr = service_requests(:submitted_request)
    sr.device_brand = nil
    assert_not sr.valid?
  end

  test "missing device_model is invalid" do
    sr = service_requests(:submitted_request)
    sr.device_model = nil
    assert_not sr.valid?
  end

  test "missing issue_description is invalid" do
    sr = service_requests(:submitted_request)
    sr.issue_description = nil
    assert_not sr.valid?
  end

  test "missing contact_info is invalid" do
    sr = service_requests(:submitted_request)
    sr.contact_info = nil
    assert_not sr.valid?
  end

  test "technician is optional" do
    sr = service_requests(:submitted_request)
    sr.technician = nil
    assert sr.valid?
  end

  # ── Status enum ─────────────────────────────────────────────────────────────

  test "status enum values are correct" do
    assert_equal 0, ServiceRequest.statuses[:submitted]
    assert_equal 1, ServiceRequest.statuses[:assigned]
    assert_equal 2, ServiceRequest.statuses[:in_diagnosis]
    assert_equal 3, ServiceRequest.statuses[:in_repair]
    assert_equal 4, ServiceRequest.statuses[:completed]
    assert_equal 5, ServiceRequest.statuses[:cancelled]
  end

  # ── Status transitions ───────────────────────────────────────────────────────

  test "submitted can transition to assigned" do
    assert service_requests(:submitted_request).can_transition_to?("assigned")
  end

  test "submitted can transition to cancelled" do
    assert service_requests(:submitted_request).can_transition_to?("cancelled")
  end

  test "submitted cannot skip to in_diagnosis" do
    assert_not service_requests(:submitted_request).can_transition_to?("in_diagnosis")
  end

  test "assigned can transition to in_diagnosis" do
    assert service_requests(:assigned_request).can_transition_to?("in_diagnosis")
  end

  test "assigned cannot skip to completed" do
    assert_not service_requests(:assigned_request).can_transition_to?("completed")
  end

  test "in_diagnosis can transition to in_repair" do
    assert service_requests(:in_diagnosis_request).can_transition_to?("in_repair")
  end

  test "completed has no valid transitions" do
    assert_empty ServiceRequest::VALID_TRANSITIONS["completed"]
  end

  test "cancelled has no valid transitions" do
    assert_empty ServiceRequest::VALID_TRANSITIONS["cancelled"]
  end

  # ── Timestamps ──────────────────────────────────────────────────────────────

  test "assigned_at set when status changes to assigned" do
    sr = service_requests(:submitted_request)
    sr.update!(status: :assigned, technician: users(:technician))
    assert_not_nil sr.assigned_at
  end

  test "completed_at set when status changes to completed" do
    sr = service_requests(:in_diagnosis_request)
    sr.update!(status: :completed)
    assert_not_nil sr.completed_at
  end
end
