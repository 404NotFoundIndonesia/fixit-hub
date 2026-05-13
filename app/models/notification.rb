class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :service_request

  validates :message, presence: true

  scope :unread,  -> { where(read_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  after_create_commit :broadcast_badge
  after_update_commit :broadcast_badge, if: :saved_change_to_read_at?

  def mark_read!
    return if read_at
    update!(read_at: Time.current)
  end

  private

  def broadcast_badge
    broadcast_replace_to(
      "notifications_user_#{user_id}",
      target: "notification_badge",
      partial: "shared/notification_badge",
      locals: { unread_count: user.notifications.unread.count }
    )
  end
end
