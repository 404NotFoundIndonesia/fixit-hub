class Message < ApplicationRecord
  belongs_to :service_request
  belongs_to :sender, class_name: "User", foreign_key: :sender_id

  validates :body, presence: true
  validate  :sender_is_participant

  after_create_commit :broadcast_to_thread

  private

  def sender_is_participant
    return unless service_request && sender

    is_customer    = sender_id == service_request.customer_id
    is_technician  = service_request.technician_id.present? &&
                     sender_id == service_request.technician_id

    unless is_customer || is_technician
      errors.add(:sender, "is not a participant in this service request")
    end
  end

  def broadcast_to_thread
    broadcast_append_to(
      "service_request_#{service_request_id}_messages",
      target: "messages_list",
      partial: "messages/message",
      locals: { message: self }
    )
  end
end
