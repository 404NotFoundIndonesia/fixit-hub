require "test_helper"

class ServiceNoteTest < ActiveSupport::TestCase
  test "valid note saves" do
    note = ServiceNote.new(
      service_request: service_requests(:assigned_request),
      technician:      users(:technician),
      note_type:       :diagnosis,
      body:            "Hard drive making clicking sounds"
    )
    assert note.valid?
  end

  test "body is required" do
    note = ServiceNote.new(
      service_request: service_requests(:assigned_request),
      technician:      users(:technician),
      note_type:       :diagnosis,
      body:            ""
    )
    assert_not note.valid?
    assert_includes note.errors[:body], "can't be blank"
  end

  test "note_type enum values are correct" do
    assert_equal 0, ServiceNote.note_types[:diagnosis]
    assert_equal 1, ServiceNote.note_types[:repair]
    assert_equal 2, ServiceNote.note_types[:completion]
  end

  test "service_request association required" do
    note = ServiceNote.new(technician: users(:technician), note_type: :diagnosis, body: "test")
    assert_not note.valid?
  end

  test "technician association required" do
    note = ServiceNote.new(service_request: service_requests(:assigned_request), note_type: :diagnosis, body: "test")
    assert_not note.valid?
  end
end
