class ServiceRequest < ApplicationRecord
  belongs_to :customer,   class_name: "User", foreign_key: :customer_id
  belongs_to :technician, class_name: "User", foreign_key: :technician_id, optional: true

  has_many :service_notes, dependent: :destroy
  has_many :messages,      dependent: :destroy

  enum status: {
    submitted:    0,
    assigned:     1,
    in_diagnosis: 2,
    in_repair:    3,
    completed:    4,
    cancelled:    5
  }

  validates :device_brand,      presence: true
  validates :device_model,      presence: true
  validates :issue_description, presence: true
  validates :contact_info,      presence: true

  VALID_TRANSITIONS = {
    "submitted"    => %w[assigned cancelled],
    "assigned"     => %w[in_diagnosis cancelled],
    "in_diagnosis" => %w[in_repair cancelled],
    "in_repair"    => %w[completed cancelled],
    "completed"    => [],
    "cancelled"    => []
  }.freeze

  STATUS_PRIORITY = %w[in_diagnosis in_repair assigned submitted completed cancelled].freeze

  def can_transition_to?(new_status)
    VALID_TRANSITIONS[status].include?(new_status.to_s)
  end

  def next_status
    VALID_TRANSITIONS[status].reject { |s| s == "cancelled" }.first
  end

  # Callbacks to track timestamps and broadcast
  before_update :set_status_timestamps
  after_update_commit :broadcast_to_admin

  private

  def set_status_timestamps
    return unless status_changed?

    self.assigned_at  = Time.current if status == "assigned"
    self.completed_at = Time.current if status == "completed"
  end

  def broadcast_to_admin
    broadcast_replace_to(
      "admin_service_requests",
      target: "service_request_#{id}",
      partial: "admin/service_requests/service_request",
      locals: { service_request: self }
    )
  end
end
