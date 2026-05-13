require "test_helper"

# Exhaustive cross-role authorization audit.
#
# For every sensitive route: unauthenticated → 302 to login; wrong role → 403;
# correct role → non-403 (200 / redirect / 422 depending on params).
#
# Helper pattern within a single test:
#   reset!         — fresh session (no user)
#   sign_in user   — sign in under fresh session
class AuthorizationTest < ActionDispatch::IntegrationTest
  # ── Private helpers ───────────────────────────────────────────────────────────

  private

  def assert_requires_auth(verb, path, params: {})
    reset!
    send(verb, path, params: params)
    assert_redirected_to new_user_session_path,
      "#{verb.upcase} #{path} — unauthenticated must redirect to login"
  end

  def assert_forbidden(verb, path, user:, params: {})
    reset!
    sign_in user
    send(verb, path, params: params)
    assert_response :forbidden,
      "#{verb.upcase} #{path} — #{user.role} must receive 403"
  end

  def assert_permitted(verb, path, user:, params: {})
    reset!
    sign_in user
    send(verb, path, params: params)
    assert_not_equal 403, response.status,
      "#{verb.upcase} #{path} — #{user.role} must not receive 403"
  end

  public

  # ═══════════════════════════════════════════════════════════════════════════
  # ADMIN NAMESPACE
  # Guards: authenticate_user! → require_admin!
  # ═══════════════════════════════════════════════════════════════════════════

  test "GET /admin/dashboard" do
    path = admin_dashboard_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:admin)
  end

  test "GET /admin/service_requests" do
    path = admin_service_requests_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:admin)
  end

  test "GET /admin/service_requests/:id" do
    path = admin_service_request_path(service_requests(:assigned_request))
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:admin)
  end

  test "PATCH /admin/service_requests/:id/assign" do
    path   = assign_admin_service_request_path(service_requests(:submitted_request))
    params = { technician_id: users(:technician).id }
    assert_requires_auth :patch, path, params: params
    assert_forbidden :patch, path, user: users(:customer),   params: params
    assert_forbidden :patch, path, user: users(:technician), params: params
    assert_permitted :patch, path, user: users(:admin),      params: params
  end

  test "GET /admin/users" do
    path = admin_users_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:admin)
  end

  test "GET /admin/users/new" do
    path = new_admin_user_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:admin)
  end

  test "POST /admin/users" do
    path   = admin_users_path
    params = { user: { email: "newtech@test.com", password: "password123",
                       password_confirmation: "password123" } }
    assert_requires_auth :post, path, params: params
    assert_forbidden :post, path, user: users(:customer),   params: params
    assert_forbidden :post, path, user: users(:technician), params: params
    assert_permitted :post, path, user: users(:admin),      params: params
  end

  test "GET /admin/users/:id/edit" do
    path = edit_admin_user_path(users(:technician))
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:admin)
  end

  test "PATCH /admin/users/:id" do
    path   = admin_user_path(users(:technician))
    params = { user: { email: users(:technician).email } }
    assert_requires_auth :patch, path, params: params
    assert_forbidden :patch, path, user: users(:customer),   params: params
    assert_forbidden :patch, path, user: users(:technician), params: params
    assert_permitted :patch, path, user: users(:admin),      params: params
  end

  test "GET /admin/customers" do
    path = admin_customers_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:admin)
  end

  test "GET /admin/customers/:id" do
    path = admin_customer_path(users(:customer))
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:admin)
  end

  test "GET /admin/analytics" do
    path = admin_analytics_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:admin)
  end

  # ═══════════════════════════════════════════════════════════════════════════
  # TECHNICIAN NAMESPACE
  # Guards: authenticate_user! → require_technician!
  # ═══════════════════════════════════════════════════════════════════════════

  test "GET /technician/dashboard" do
    path = technician_dashboard_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:admin)
    assert_permitted :get, path, user: users(:technician)
  end

  test "GET /technician/service_requests" do
    path = technician_service_requests_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:admin)
    assert_permitted :get, path, user: users(:technician)
  end

  test "GET /technician/service_requests/:id" do
    path = technician_service_request_path(service_requests(:assigned_request))
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:customer)
    assert_forbidden :get, path, user: users(:admin)
    assert_permitted :get, path, user: users(:technician)
  end

  test "PATCH /technician/service_requests/:id/update_status" do
    path   = update_status_technician_service_request_path(service_requests(:assigned_request))
    params = { status: "in_diagnosis" }
    assert_requires_auth :patch, path, params: params
    assert_forbidden :patch, path, user: users(:customer),   params: params
    assert_forbidden :patch, path, user: users(:admin),      params: params
    assert_permitted :patch, path, user: users(:technician), params: params
  end

  test "POST /technician/service_requests/:id/service_notes" do
    path   = technician_service_request_service_notes_path(service_requests(:assigned_request))
    params = { service_note: { note_type: "diagnosis", body: "Test note" } }
    assert_requires_auth :post, path, params: params
    assert_forbidden :post, path, user: users(:customer),   params: params
    assert_forbidden :post, path, user: users(:admin),      params: params
    assert_permitted :post, path, user: users(:technician), params: params
  end

  # ═══════════════════════════════════════════════════════════════════════════
  # CUSTOMER NAMESPACE
  # Guards: authenticate_user! → require_customer!
  # ═══════════════════════════════════════════════════════════════════════════

  test "GET /customer/dashboard" do
    path = customer_dashboard_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:admin)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:customer)
  end

  test "GET /customer/service_requests" do
    path = customer_service_requests_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:admin)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:customer)
  end

  test "GET /customer/service_requests/new" do
    path = new_customer_service_request_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:admin)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:customer)
  end

  test "GET /customer/service_requests/:id" do
    path = customer_service_request_path(service_requests(:assigned_request))
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:admin)
    assert_forbidden :get, path, user: users(:technician)
    assert_permitted :get, path, user: users(:customer)
  end

  test "POST /customer/service_requests" do
    path   = customer_service_requests_path
    params = { service_request: { device_brand: "HP", device_model: "Pavilion",
                                  issue_description: "Broken screen",
                                  contact_info: "test@example.com" } }
    assert_requires_auth :post, path, params: params
    assert_forbidden :post, path, user: users(:admin),      params: params
    assert_forbidden :post, path, user: users(:technician), params: params
    assert_permitted :post, path, user: users(:customer),   params: params
  end

  # ═══════════════════════════════════════════════════════════════════════════
  # NOTIFICATIONS (shared — customers and technicians only, admin blocked)
  # Guards: authenticate_user! → ensure_not_admin!
  # ═══════════════════════════════════════════════════════════════════════════

  test "GET /notifications" do
    path = notifications_path
    assert_requires_auth :get, path
    assert_forbidden :get, path, user: users(:admin)
    assert_permitted :get, path, user: users(:customer)
    assert_permitted :get, path, user: users(:technician)
  end

  test "PATCH /notifications/:id/mark_as_read" do
    # Each user can only mark their own notifications — test with matching ownership
    assert_requires_auth :patch, mark_as_read_notification_path(notifications(:unread_notification))
    assert_forbidden :patch, mark_as_read_notification_path(notifications(:unread_notification)),
                     user: users(:admin)
    # Customer marking their own notification
    assert_permitted :patch, mark_as_read_notification_path(notifications(:unread_notification)),
                     user: users(:customer)
    # Technician marking their own notification
    assert_permitted :patch, mark_as_read_notification_path(notifications(:technician_notification)),
                     user: users(:technician)
  end

  # ═══════════════════════════════════════════════════════════════════════════
  # MESSAGES (participant guard — customer owner OR assigned technician only)
  # Guards: authenticate_user! → authorize_participant!
  # ═══════════════════════════════════════════════════════════════════════════

  test "POST /service_requests/:id/messages" do
    path   = service_request_messages_path(service_requests(:assigned_request))
    params = { message: { body: "Hello" } }

    assert_requires_auth :post, path, params: params

    # Admin is not a participant
    assert_forbidden :post, path, user: users(:admin), params: params

    # Unrelated customer (not owner of this request)
    other_customer = User.create!(email: "other@example.com", password: "pass1234", role: :customer)
    assert_forbidden :post, path, user: other_customer, params: params

    # Unrelated technician (not assigned to this request)
    other_tech = User.create!(email: "other_tech@example.com", password: "pass1234", role: :technician)
    assert_forbidden :post, path, user: other_tech, params: params

    # Owner customer is permitted
    assert_permitted :post, path, user: users(:customer), params: params

    # Assigned technician is permitted
    assert_permitted :post, path, user: users(:technician), params: params
  end
end
