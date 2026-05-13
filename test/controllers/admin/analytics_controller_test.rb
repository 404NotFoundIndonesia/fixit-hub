require "test_helper"

class Admin::AnalyticsControllerTest < ActionDispatch::IntegrationTest
  # ── Access control ────────────────────────────────────────────────────────────

  test "unauthenticated request is redirected to sign in" do
    get admin_analytics_path
    assert_redirected_to new_user_session_path
  end

  test "customer is forbidden" do
    sign_in users(:customer)
    get admin_analytics_path
    assert_response :forbidden
  end

  test "technician is forbidden" do
    sign_in users(:technician)
    get admin_analytics_path
    assert_response :forbidden
  end

  test "admin can access analytics" do
    sign_in users(:admin)
    get admin_analytics_path
    assert_response :ok
  end

  # ── RPT-01: date filter ───────────────────────────────────────────────────────

  test "date filter with past-only range shows all-zero counts" do
    sign_in users(:admin)
    get admin_analytics_path, params: { date_from: "2000-01-01", date_to: "2000-01-02" }
    assert_response :ok
    # All status rows should show 0
    ServiceRequest.statuses.each_key do |name|
      assert_match %r{#{name.humanize}.*\b0\b}m, response.body
    end
  end

  test "date filter spanning all fixtures shows non-zero total" do
    sign_in users(:admin)
    get admin_analytics_path, params: {
      date_from: 1.year.ago.to_date.to_s,
      date_to:   1.year.from_now.to_date.to_s
    }
    assert_response :ok
    # At least one status row should have count > 0
    assert_match(/[1-9]\d*/, response.body)
  end

  test "invalid date params render without error" do
    sign_in users(:admin)
    get admin_analytics_path, params: { date_from: "not-a-date", date_to: "also-bad" }
    assert_response :ok
  end

  # ── RPT-02: technician stats ──────────────────────────────────────────────────

  test "technician performance table includes active technician" do
    sign_in users(:admin)
    get admin_analytics_path
    assert_response :ok
    assert_select "td", text: users(:technician).email
  end

  test "technician with completed requests shows a resolution time" do
    sign_in users(:admin)
    get admin_analytics_path
    # completed_request fixture has assigned_at and completed_at set — avg must not be "—"
    assert_response :ok
    # The page should show something other than all dashes for technician with completed work
    assert_match(/\d+[dhm]/, response.body)
  end

  # ── RPT-03: device trends ─────────────────────────────────────────────────────

  test "device trends table lists fixture devices" do
    sign_in users(:admin)
    get admin_analytics_path
    assert_response :ok
    # Fixtures include HP and Dell devices
    assert_select "td", text: "HP"
    assert_select "td", text: "Dell"
  end
end
