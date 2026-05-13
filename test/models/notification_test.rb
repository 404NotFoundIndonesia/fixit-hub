require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  # ── Scopes ───────────────────────────────────────────────────────────────────

  test "unread scope returns only unread notifications" do
    assert_includes     Notification.unread, notifications(:unread_notification)
    assert_includes     Notification.unread, notifications(:technician_notification)
    assert_not_includes Notification.unread, notifications(:read_notification)
  end

  test "recent scope orders by created_at descending" do
    order = Notification.recent.pluck(:created_at)
    assert_equal order.sort.reverse, order
  end

  # ── mark_read! ───────────────────────────────────────────────────────────────

  test "mark_read! sets read_at on unread notification" do
    n = notifications(:unread_notification)
    assert_nil n.read_at
    n.mark_read!
    assert_not_nil n.reload.read_at
  end

  test "mark_read! is idempotent — does not overwrite existing read_at" do
    n        = notifications(:read_notification)
    original = n.read_at
    n.mark_read!
    assert_equal original, n.reload.read_at
  end

  # ── Validation ───────────────────────────────────────────────────────────────

  test "notification requires a message" do
    n = Notification.new(
      user:            users(:customer),
      service_request: service_requests(:assigned_request),
      message:         ""
    )
    assert_not n.valid?
    assert_includes n.errors[:message], "can't be blank"
  end

  test "valid notification saves" do
    n = Notification.new(
      user:            users(:customer),
      service_request: service_requests(:assigned_request),
      message:         "Status changed."
    )
    assert n.valid?
  end
end
