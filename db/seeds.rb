puts "Seeding FixIT Hub demo data..."

# Suppress ActionCable broadcasts — no server is running during seeding
Message.skip_callback     :commit, :after, :broadcast_to_thread
Message.skip_callback     :commit, :after, :notify_customer_of_message
ServiceNote.skip_callback :commit, :after, :broadcast_to_technician

# ── Helpers ───────────────────────────────────────────────────────────────────

def find_or_create_user(email:, password:, role:)
  user = User.find_or_initialize_by(email: email)
  if user.new_record?
    user.password              = password
    user.password_confirmation = password
    user.role                  = role
    user.active                = true
    user.save!
    puts "  [+] #{role.to_s.capitalize.ljust(12)} #{email}"
  end
  user
end

def find_or_create_service_request(attrs)
  sr = ServiceRequest.find_by(
    customer_id:  attrs[:customer_id],
    device_brand: attrs[:device_brand],
    device_model: attrs[:device_model]
  )
  unless sr
    sr = ServiceRequest.create!(attrs)
    puts "  [+] ServiceRequest ##{sr.id.to_s.ljust(4)} #{attrs[:device_brand]} #{attrs[:device_model]} (#{attrs[:status]})"
  end
  sr
end

# ── Admin ─────────────────────────────────────────────────────────────────────

puts "\nUsers:"
admin = find_or_create_user(email: "admin@fixithub.com", password: "Admin1234!", role: :admin)

# ── Technicians ───────────────────────────────────────────────────────────────

tech1 = find_or_create_user(email: "tech1@fixithub.com", password: "Tech1234!", role: :technician)
tech2 = find_or_create_user(email: "tech2@fixithub.com", password: "Tech1234!", role: :technician)
tech3 = find_or_create_user(email: "tech3@fixithub.com", password: "Tech1234!", role: :technician)

# ── Customers ─────────────────────────────────────────────────────────────────

cust1 = find_or_create_user(email: "customer1@fixithub.com", password: "Customer1234!", role: :customer)
cust2 = find_or_create_user(email: "customer2@fixithub.com", password: "Customer1234!", role: :customer)
cust3 = find_or_create_user(email: "customer3@fixithub.com", password: "Customer1234!", role: :customer)
cust4 = find_or_create_user(email: "customer4@fixithub.com", password: "Customer1234!", role: :customer)
cust5 = find_or_create_user(email: "customer5@fixithub.com", password: "Customer1234!", role: :customer)

# ── Service Requests ──────────────────────────────────────────────────────────

puts "\nService Requests:"

# 1 — Submitted (no technician)
sr_submitted = find_or_create_service_request(
  customer_id:       cust1.id,
  device_brand:      "HP",
  device_model:      "Pavilion 15",
  serial_number:     "SN-DEMO-001",
  issue_description: "Screen flickering intermittently and sometimes goes completely black.",
  contact_info:      cust1.email,
  status:            :submitted
)

# 2 — Assigned
sr_assigned = find_or_create_service_request(
  customer_id:       cust2.id,
  technician_id:     tech1.id,
  device_brand:      "Dell",
  device_model:      "Inspiron 14",
  serial_number:     "SN-DEMO-002",
  issue_description: "Battery drains from 100% to 0% in under 30 minutes of use.",
  contact_info:      cust2.email,
  status:            :assigned,
  assigned_at:       2.days.ago
)

# 3 — In Diagnosis
sr_in_diagnosis = find_or_create_service_request(
  customer_id:       cust3.id,
  technician_id:     tech2.id,
  device_brand:      "Lenovo",
  device_model:      "ThinkPad X1 Carbon",
  serial_number:     "SN-DEMO-003",
  issue_description: "Keyboard keys sticking and intermittent Wi-Fi disconnections.",
  contact_info:      cust3.email,
  status:            :in_diagnosis,
  assigned_at:       3.days.ago
)

# 4 — In Repair
sr_in_repair = find_or_create_service_request(
  customer_id:       cust4.id,
  technician_id:     tech3.id,
  device_brand:      "Asus",
  device_model:      "VivoBook 14",
  serial_number:     "SN-DEMO-004",
  issue_description: "Laptop overheating and shutting down under light load.",
  contact_info:      cust4.email,
  status:            :in_repair,
  assigned_at:       5.days.ago
)

# 5 — Completed (full notes + messages)
sr_completed = find_or_create_service_request(
  customer_id:       cust5.id,
  technician_id:     tech1.id,
  device_brand:      "HP",
  device_model:      "EliteBook 840 G8",
  serial_number:     "SN-DEMO-005",
  issue_description: "Battery health severely degraded — cannot hold charge for more than 1 hour.",
  contact_info:      cust5.email,
  status:            :completed,
  assigned_at:       10.days.ago,
  completed_at:      7.days.ago
)

# 6 — Cancelled
sr_cancelled = find_or_create_service_request(
  customer_id:       cust1.id,
  device_brand:      "HP",
  device_model:      "Spectre x360",
  serial_number:     "SN-DEMO-006",
  issue_description: "Touchscreen not responding to touch inputs.",
  contact_info:      cust1.email,
  status:            :cancelled
)

# ── Service Notes ─────────────────────────────────────────────────────────────

puts "\nService Notes:"

if sr_in_repair.service_notes.none?
  sr_in_repair.service_notes.create!(
    technician: tech3,
    note_type:  :diagnosis,
    body:       "Thermal paste on CPU completely dried out. Heatsink has significant dust buildup blocking airflow. Fan running at max RPM continuously. Recommend full thermal system service."
  )
  puts "  [+] Diagnosis note for #{sr_in_repair.device_brand} #{sr_in_repair.device_model}"
end

if sr_completed.service_notes.none?
  sr_completed.service_notes.create!(
    technician: tech1,
    note_type:  :diagnosis,
    body:       "Battery health measured at 12% of original capacity (6Wh of 50Wh). Cells are swollen and no longer charging properly. Immediate replacement required."
  )
  sr_completed.service_notes.create!(
    technician: tech1,
    note_type:  :repair,
    body:       "Replaced original battery with genuine HP 4-cell 56Wh lithium-ion battery (PN: L07044-855). All connector pins inspected and secured. BIOS battery calibration performed."
  )
  sr_completed.service_notes.create!(
    technician: tech1,
    note_type:  :completion,
    body:       "Battery replacement successful. New battery capacity at 100% (56Wh). Device stress-tested for 4 hours under full load with no thermal or power issues. Ready for customer pickup."
  )
  puts "  [+] 3 notes (diagnosis, repair, completion) for #{sr_completed.device_brand} #{sr_completed.device_model}"
end

# ── Messages ──────────────────────────────────────────────────────────────────

puts "\nMessages:"

if sr_in_diagnosis.messages.none?
  sr_in_diagnosis.messages.create!(sender: cust3,
    body: "Hi, any updates on the diagnosis? It has been a couple of days.")
  sr_in_diagnosis.messages.create!(sender: tech2,
    body: "Hello! We are running a full hardware diagnostic. The keyboard issue looks like a firmware conflict. Should have a detailed update by tomorrow.")
  sr_in_diagnosis.messages.create!(sender: cust3,
    body: "Thanks for the update. Looking forward to hearing from you.")
  puts "  [+] 3 messages on #{sr_in_diagnosis.device_brand} #{sr_in_diagnosis.device_model}"
end

if sr_completed.messages.none?
  sr_completed.messages.create!(sender: cust5,
    body: "Hi, do you have an update on my laptop? Just checking in.")
  sr_completed.messages.create!(sender: tech1,
    body: "Great news! The battery replacement is complete. Your laptop is fully tested and ready for pickup.")
  sr_completed.messages.create!(sender: cust5,
    body: "Wonderful! I will come in tomorrow morning to collect it. Thank you so much!")
  sr_completed.messages.create!(sender: tech1,
    body: "Perfect — we will have it waiting for you. Please bring your service receipt.")
  puts "  [+] 4 messages on #{sr_completed.device_brand} #{sr_completed.device_model}"
end

# ── Summary ───────────────────────────────────────────────────────────────────

puts "\n#{"=" * 60}"
puts "  Seeding complete!"
puts "=" * 60
puts ""
puts "  Demo accounts (all passwords shown below):"
puts ""
puts "  ADMIN"
puts "    admin@fixithub.com        / Admin1234!"
puts ""
puts "  TECHNICIANS"
puts "    tech1@fixithub.com        / Tech1234!"
puts "    tech2@fixithub.com        / Tech1234!"
puts "    tech3@fixithub.com        / Tech1234!"
puts ""
puts "  CUSTOMERS"
puts "    customer1@fixithub.com    / Customer1234!"
puts "    customer2@fixithub.com    / Customer1234!"
puts "    customer3@fixithub.com    / Customer1234!"
puts "    customer4@fixithub.com    / Customer1234!"
puts "    customer5@fixithub.com    / Customer1234!"
puts ""
puts "  Service requests span all statuses:"
puts "    submitted · assigned · in_diagnosis · in_repair · completed · cancelled"
puts ""
