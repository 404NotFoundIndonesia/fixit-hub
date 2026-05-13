require "test_helper"

class Technician::ServiceNotesControllerTest < ActionDispatch::IntegrationTest
  test "technician can add a note" do
    sign_in users(:technician)
    assert_difference("ServiceNote.count") do
      post technician_service_request_service_notes_path(service_requests(:assigned_request)),
           params: { service_note: { body: "Inspected motherboard", note_type: "diagnosis" } }
    end
  end

  test "missing body returns error" do
    sign_in users(:technician)
    assert_no_difference("ServiceNote.count") do
      post technician_service_request_service_notes_path(service_requests(:assigned_request)),
           params: { service_note: { body: "", note_type: "diagnosis" } }
    end
  end

  test "customer blocked from adding notes" do
    sign_in users(:customer)
    post technician_service_request_service_notes_path(service_requests(:assigned_request)),
         params: { service_note: { body: "test", note_type: "diagnosis" } }
    assert_response :forbidden
  end

  test "technician cannot add notes to another technician's request" do
    other_tech = User.create!(email: "other2@example.com", password: "password123", role: :technician)
    sign_in other_tech
    post technician_service_request_service_notes_path(service_requests(:assigned_request)),
         params: { service_note: { body: "test", note_type: "diagnosis" } }
    assert_response :not_found
  end
end
