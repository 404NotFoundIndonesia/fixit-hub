require "test_helper"

class MessageTest < ActiveSupport::TestCase
  # ── Validity ─────────────────────────────────────────────────────────────────

  test "customer can send a valid message" do
    msg = Message.new(
      service_request: service_requests(:assigned_request),
      sender:          users(:customer),
      body:            "Is my laptop ready?"
    )
    assert msg.valid?
  end

  test "assigned technician can send a valid message" do
    msg = Message.new(
      service_request: service_requests(:assigned_request),
      sender:          users(:technician),
      body:            "Almost done, one more day."
    )
    assert msg.valid?
  end

  test "body cannot be blank" do
    msg = Message.new(
      service_request: service_requests(:assigned_request),
      sender:          users(:customer),
      body:            ""
    )
    assert_not msg.valid?
    assert_includes msg.errors[:body], "can't be blank"
  end

  # ── Participant guard ─────────────────────────────────────────────────────────

  test "unrelated customer cannot send a message" do
    other = User.create!(email: "other@example.com", password: "password123", role: :customer)
    msg = Message.new(
      service_request: service_requests(:assigned_request),
      sender:          other,
      body:            "I am not involved"
    )
    assert_not msg.valid?
    assert_includes msg.errors[:sender], "is not a participant in this service request"
  end

  test "unassigned technician cannot send a message" do
    other_tech = User.create!(email: "other_tech@example.com", password: "password123", role: :technician)
    msg = Message.new(
      service_request: service_requests(:assigned_request),
      sender:          other_tech,
      body:            "I shouldn't be here"
    )
    assert_not msg.valid?
    assert_includes msg.errors[:sender], "is not a participant in this service request"
  end

  test "admin cannot send a message" do
    msg = Message.new(
      service_request: service_requests(:assigned_request),
      sender:          users(:admin),
      body:            "Admin message"
    )
    assert_not msg.valid?
  end

  test "message on unassigned request is only valid from customer" do
    msg = Message.new(
      service_request: service_requests(:submitted_request),
      sender:          users(:customer),
      body:            "Hello?"
    )
    assert msg.valid?
  end
end
