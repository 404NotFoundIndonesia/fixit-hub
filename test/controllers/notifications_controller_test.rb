require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  # ── Access control ────────────────────────────────────────────────────────────

  test "unauthenticated request redirected to sign in" do
    get notifications_path
    assert_redirected_to new_user_session_path
  end

  test "admin is forbidden" do
    sign_in users(:admin)
    get notifications_path
    assert_response :forbidden
  end

  # ── index ─────────────────────────────────────────────────────────────────────

  test "customer can view their notifications" do
    sign_in users(:customer)
    get notifications_path
    assert_response :ok
    assert_select "##{dom_id(notifications(:unread_notification))}"
    assert_select "##{dom_id(notifications(:read_notification))}"
  end

  test "technician can view their notifications" do
    sign_in users(:technician)
    get notifications_path
    assert_response :ok
    assert_select "##{dom_id(notifications(:technician_notification))}"
  end

  test "customer cannot see other users notifications" do
    sign_in users(:customer)
    get notifications_path
    assert_select "##{dom_id(notifications(:technician_notification))}", count: 0
  end

  # ── mark_as_read ─────────────────────────────────────────────────────────────

  test "customer can mark their own notification as read" do
    sign_in users(:customer)
    n = notifications(:unread_notification)
    assert_nil n.read_at
    patch mark_as_read_notification_path(n)
    assert_not_nil n.reload.read_at
  end

  test "mark_as_read redirects to notifications on html format" do
    sign_in users(:customer)
    patch mark_as_read_notification_path(notifications(:unread_notification)),
          headers: { "Accept" => "text/html" }
    assert_redirected_to notifications_path
  end

  test "cannot mark another user's notification as read" do
    sign_in users(:technician)
    assert_raises(ActiveRecord::RecordNotFound) do
      patch mark_as_read_notification_path(notifications(:unread_notification))
    end
  end
end
