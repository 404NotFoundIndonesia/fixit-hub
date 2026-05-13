require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  # ── index ────────────────────────────────────────────────────────────────────

  test "admin can list technicians" do
    sign_in users(:admin)
    get admin_users_path
    assert_response :success
  end

  test "customer blocked from technician list" do
    sign_in users(:customer)
    get admin_users_path
    assert_response :forbidden
  end

  test "technician blocked from technician list" do
    sign_in users(:technician)
    get admin_users_path
    assert_response :forbidden
  end

  # ── new/create ───────────────────────────────────────────────────────────────

  test "admin can access new technician form" do
    sign_in users(:admin)
    get new_admin_user_path
    assert_response :success
  end

  test "admin can create a technician" do
    sign_in users(:admin)
    assert_difference("User.technician.count") do
      post admin_users_path, params: {
        user: {
          email:                 "newtech@fixithub.test",
          password:              "password123",
          password_confirmation: "password123"
        }
      }
    end
    created = User.find_by(email: "newtech@fixithub.test")
    assert_not_nil created
    assert created.technician?
    assert created.active?
    assert_redirected_to admin_users_path
  end

  test "invalid create re-renders form" do
    sign_in users(:admin)
    assert_no_difference("User.count") do
      post admin_users_path, params: {
        user: { email: "", password: "pass", password_confirmation: "different" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "role cannot be overridden via params" do
    sign_in users(:admin)
    post admin_users_path, params: {
      user: {
        email:                 "hackr@fixithub.test",
        password:              "password123",
        password_confirmation: "password123",
        role:                  "admin"
      }
    }
    user = User.find_by(email: "hackr@fixithub.test")
    assert_not_nil user
    assert user.technician?, "role should be forced to technician regardless of params"
  end

  # ── edit/update ──────────────────────────────────────────────────────────────

  test "admin can access edit form" do
    sign_in users(:admin)
    get edit_admin_user_path(users(:technician))
    assert_response :success
  end

  test "admin can update technician email" do
    sign_in users(:admin)
    patch admin_user_path(users(:technician)), params: {
      user: { email: "updated@fixithub.test" }
    }
    assert_equal "updated@fixithub.test", users(:technician).reload.email
    assert_redirected_to admin_users_path
  end

  test "admin can deactivate a technician" do
    sign_in users(:admin)
    patch admin_user_path(users(:technician)), params: {
      user: { active: "0" }
    }
    assert_not users(:technician).reload.active?
    assert_redirected_to admin_users_path
  end

  test "admin can reactivate a technician" do
    sign_in users(:admin)
    patch admin_user_path(users(:inactive_technician)), params: {
      user: { active: "1" }
    }
    assert users(:inactive_technician).reload.active?
  end

  test "blank password on update preserves existing password" do
    sign_in users(:admin)
    old_password = users(:technician).encrypted_password
    patch admin_user_path(users(:technician)), params: {
      user: { email: users(:technician).email, password: "", password_confirmation: "" }
    }
    assert_equal old_password, users(:technician).reload.encrypted_password
  end

  test "edit returns 404 for non-technician user" do
    sign_in users(:admin)
    get edit_admin_user_path(users(:customer))
    assert_response :not_found
  end

  # ── deactivated login ─────────────────────────────────────────────────────

  test "deactivated technician cannot sign in" do
    post user_session_path, params: {
      user: { email: users(:inactive_technician).email, password: "password123" }
    }
    # Devise redirects back to sign-in on authentication failure
    assert_redirected_to new_user_session_path
    follow_redirect!
    # Flash message should reference the deactivated state
    assert_match /deactivated/i, flash[:alert].to_s
  end
end
