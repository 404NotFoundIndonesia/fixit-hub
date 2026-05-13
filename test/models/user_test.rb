require "test_helper"

class UserTest < ActiveSupport::TestCase
  # --- Validity ---

  test "valid customer saves" do
    user = User.new(email: "new@example.com", password: "password123", role: :customer)
    assert user.valid?
  end

  test "missing email is invalid" do
    user = User.new(password: "password123", role: :customer)
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "duplicate email is invalid" do
    User.create!(email: "dup@example.com", password: "password123", role: :customer)
    user = User.new(email: "dup@example.com", password: "password123", role: :customer)
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "short password is invalid" do
    user = User.new(email: "x@example.com", password: "short", role: :customer)
    assert_not user.valid?
  end

  # --- Role enum ---

  test "role enum values are correct" do
    assert_equal 0, User.roles[:customer]
    assert_equal 1, User.roles[:technician]
    assert_equal 2, User.roles[:admin]
  end

  test "role helper methods return correct boolean" do
    assert users(:admin).admin?
    assert_not users(:admin).customer?
    assert_not users(:admin).technician?

    assert users(:technician).technician?
    assert_not users(:technician).admin?

    assert users(:customer).customer?
    assert_not users(:customer).admin?
  end

  # --- active_for_authentication? ---

  test "active user can authenticate" do
    assert users(:technician).active_for_authentication?
  end

  test "inactive user cannot authenticate" do
    assert_not users(:inactive_technician).active_for_authentication?
  end

  test "inactive user returns deactivated message" do
    assert_equal :account_deactivated, users(:inactive_technician).inactive_message
  end

  # --- attr_readonly on role ---

  test "role cannot be changed via update" do
    user = users(:customer)
    original_role = user.role
    user.update(role: :admin)
    user.reload
    assert_equal original_role, user.role
  end
end
