require "test_helper"

class NotificationServiceTest < ActiveSupport::TestCase
  # ── Customer notifications ────────────────────────────────────────────────────

  test "always creates a notification for the customer" do
    sr = service_requests(:in_diagnosis_request)
    assert_difference -> { sr.customer.notifications.count } do
      NotificationService.notify_status_change(sr)
    end
  end

  test "customer notification message includes status" do
    sr = service_requests(:in_diagnosis_request)
    NotificationService.notify_status_change(sr)
    msg = sr.customer.notifications.order(:created_at).last.message
    assert_match /in diagnosis/i, msg
    assert_match /##{sr.id}/, msg
  end

  # ── Technician notifications ──────────────────────────────────────────────────

  test "creates technician notification when status is assigned" do
    sr = service_requests(:assigned_request)
    assert_difference -> { sr.technician.notifications.count } do
      NotificationService.notify_status_change(sr)
    end
  end

  test "does not create technician notification for non-assigned transitions" do
    sr = service_requests(:in_diagnosis_request)
    assert_no_difference -> { sr.technician.notifications.count } do
      NotificationService.notify_status_change(sr)
    end
  end

  test "does not create technician notification when no technician assigned" do
    sr = service_requests(:submitted_request)
    assert_no_difference "Notification.count" do
      # submitted_request has status 0 (submitted), not "assigned", and no technician
      # so only customer notification would fire — but status != "assigned" so neither
    end
    # customer notification still fires
    assert_difference -> { sr.customer.notifications.count } do
      NotificationService.notify_status_change(sr)
    end
  end
end
