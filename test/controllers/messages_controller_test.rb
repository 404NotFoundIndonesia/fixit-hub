require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  # ── Customer can send ─────────────────────────────────────────────────────────

  test "customer can create a message in their own thread" do
    sign_in users(:customer)
    assert_difference("Message.count") do
      post service_request_messages_path(service_requests(:assigned_request)),
           params: { message: { body: "Any updates?" } }
    end
    assert_equal users(:customer), Message.last.sender
  end

  test "assigned technician can create a message in the thread" do
    sign_in users(:technician)
    assert_difference("Message.count") do
      post service_request_messages_path(service_requests(:assigned_request)),
           params: { message: { body: "Working on it!" } }
    end
    assert_equal users(:technician), Message.last.sender
  end

  # ── Access control ────────────────────────────────────────────────────────────

  test "unauthenticated request is redirected to sign in" do
    post service_request_messages_path(service_requests(:assigned_request)),
         params: { message: { body: "test" } }
    assert_redirected_to new_user_session_path
  end

  test "unrelated customer is forbidden" do
    other = User.create!(email: "other@example.com", password: "password123", role: :customer)
    sign_in other
    post service_request_messages_path(service_requests(:assigned_request)),
         params: { message: { body: "Not my request" } }
    assert_response :forbidden
  end

  test "unassigned technician is forbidden" do
    other_tech = User.create!(email: "other_tech@example.com", password: "password123", role: :technician)
    sign_in other_tech
    post service_request_messages_path(service_requests(:assigned_request)),
         params: { message: { body: "Not assigned to me" } }
    assert_response :forbidden
  end

  test "admin is forbidden from sending messages" do
    sign_in users(:admin)
    post service_request_messages_path(service_requests(:assigned_request)),
         params: { message: { body: "Admin message" } }
    assert_response :forbidden
  end

  # ── Validation ────────────────────────────────────────────────────────────────

  test "empty body does not create a message" do
    sign_in users(:customer)
    assert_no_difference("Message.count") do
      post service_request_messages_path(service_requests(:assigned_request)),
           params: { message: { body: "" } }
    end
  end
end
