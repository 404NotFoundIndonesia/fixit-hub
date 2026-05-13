# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_05_13_060400) do
  create_table "messages", force: :cascade do |t|
    t.integer "service_request_id", null: false
    t.integer "sender_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sender_id"], name: "index_messages_on_sender_id"
    t.index ["service_request_id"], name: "index_messages_on_service_request_id"
  end

  create_table "service_notes", force: :cascade do |t|
    t.integer "service_request_id", null: false
    t.integer "technician_id", null: false
    t.integer "note_type", default: 0, null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_type"], name: "index_service_notes_on_note_type"
    t.index ["service_request_id"], name: "index_service_notes_on_service_request_id"
    t.index ["technician_id"], name: "index_service_notes_on_technician_id"
  end

  create_table "service_requests", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.integer "technician_id"
    t.string "device_brand", null: false
    t.string "device_model", null: false
    t.string "serial_number"
    t.text "issue_description", null: false
    t.string "contact_info", null: false
    t.integer "status", default: 0, null: false
    t.datetime "assigned_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_service_requests_on_customer_id"
    t.index ["status"], name: "index_service_requests_on_status"
    t.index ["technician_id"], name: "index_service_requests_on_technician_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "messages", "service_requests"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "service_notes", "service_requests"
  add_foreign_key "service_notes", "users", column: "technician_id"
  add_foreign_key "service_requests", "users", column: "customer_id"
  add_foreign_key "service_requests", "users", column: "technician_id"
end
