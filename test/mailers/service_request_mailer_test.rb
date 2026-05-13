require "test_helper"

class ServiceRequestMailerTest < ActionMailer::TestCase
  # ── status_changed ────────────────────────────────────────────────────────────

  test "status_changed sends to customer" do
    mail = ServiceRequestMailer.status_changed(service_requests(:assigned_request))
    assert_equal [users(:customer).email], mail.to
  end

  test "status_changed has correct subject" do
    sr   = service_requests(:assigned_request)
    mail = ServiceRequestMailer.status_changed(sr)
    assert_match /status update/i, mail.subject
    assert_match /##{sr.id}/, mail.subject
  end

  test "status_changed body includes status and device info" do
    sr   = service_requests(:assigned_request)
    mail = ServiceRequestMailer.status_changed(sr)
    assert_match /assigned/i,          mail.body.encoded
    assert_match sr.device_brand,      mail.body.encoded
    assert_match sr.device_model,      mail.body.encoded
  end

  # ── new_message ──────────────────────────────────────────────────────────────

  test "new_message sends to customer" do
    mail = ServiceRequestMailer.new_message(messages(:technician_message))
    assert_equal [users(:customer).email], mail.to
  end

  test "new_message has correct subject" do
    sr   = service_requests(:assigned_request)
    mail = ServiceRequestMailer.new_message(messages(:technician_message))
    assert_match /new message/i, mail.subject
    assert_match /##{sr.id}/,    mail.subject
  end

  test "new_message body includes message content" do
    mail = ServiceRequestMailer.new_message(messages(:technician_message))
    assert_match messages(:technician_message).body, mail.body.encoded
  end
end
