require "test_helper"

class ServiceRequestChannelTest < ActionCable::Channel::TestCase
  # ── Successful subscription ───────────────────────────────────────────────────

  test "customer subscribes successfully to their own thread" do
    stub_connection current_user: users(:customer)
    subscribe id: service_requests(:assigned_request).id
    assert subscription.confirmed?
    assert_has_stream "service_request_#{service_requests(:assigned_request).id}_messages"
  end

  test "assigned technician subscribes successfully" do
    stub_connection current_user: users(:technician)
    subscribe id: service_requests(:assigned_request).id
    assert subscription.confirmed?
    assert_has_stream "service_request_#{service_requests(:assigned_request).id}_messages"
  end

  # ── Rejected subscriptions ────────────────────────────────────────────────────

  test "unrelated customer subscription is rejected" do
    other = User.create!(email: "other@example.com", password: "password123", role: :customer)
    stub_connection current_user: other
    subscribe id: service_requests(:assigned_request).id
    assert subscription.rejected?
  end

  test "unassigned technician subscription is rejected" do
    other_tech = User.create!(email: "other_tech@example.com", password: "password123", role: :technician)
    stub_connection current_user: other_tech
    subscribe id: service_requests(:assigned_request).id
    assert subscription.rejected?
  end

  test "admin subscription is rejected" do
    stub_connection current_user: users(:admin)
    subscribe id: service_requests(:assigned_request).id
    assert subscription.rejected?
  end

  test "subscription to non-existent service request is rejected" do
    stub_connection current_user: users(:customer)
    subscribe id: 0
    assert subscription.rejected?
  end

  # ── Broadcast ────────────────────────────────────────────────────────────────

  test "creating a message broadcasts to the thread stream" do
    stub_connection current_user: users(:customer)
    subscribe id: service_requests(:assigned_request).id

    assert_broadcasts("service_request_#{service_requests(:assigned_request).id}_messages", 1) do
      service_requests(:assigned_request).messages.create!(
        sender: users(:customer),
        body:   "Is it ready?"
      )
    end
  end
end
