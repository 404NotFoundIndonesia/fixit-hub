class ServiceNote < ApplicationRecord
  belongs_to :service_request
  belongs_to :technician, class_name: "User", foreign_key: :technician_id

  enum note_type: { diagnosis: 0, repair: 1, completion: 2 }

  validates :body, presence: true

  after_create_commit :broadcast_to_technician

  private

  def broadcast_to_technician
    broadcast_append_to(
      "service_request_#{service_request_id}_notes",
      target: "service_notes_list",
      partial: "technician/service_notes/service_note",
      locals: { service_note: self }
    )
  end
end
