# FixIT Hub — Task Breakdown

Derived from PRD v1.0 (2026-05-13). Tasks ordered by dependency. Complete each phase before starting next.

Status legend: `[ ]` pending · `[x]` done

---

## Phase 1 — Foundation

### T01 · Devise Authentication Setup
- [ ] **Task**

  Add Devise gem, install it, generate `User` model with email + password auth. Configure sign-in, sign-out, registration routes. Customers self-register; admins create technician accounts (no public signup for technician/admin).

- **Expected Output**
  - `devise` gem in `Gemfile`
  - `User` model with Devise modules: `database_authenticatable`, `registerable` (customer only), `recoverable`, `rememberable`, `validatable`
  - Devise views generated and placed in `app/views/devise/`
  - `config/initializers/devise.rb` configured
  - Routes: `devise_for :users` with scoped constraints for role-gated registration

- **Definition of Done**
  - Customer can register, log in, log out via `/users/sign_up` and `/users/sign_in`
  - Unauthenticated requests redirect to sign-in
  - Password recovery flow works (email sent in test mode)

- **Tests**
  - `test/models/user_test.rb` — valid user saves; invalid email/password rejected; duplicate email rejected
  - `test/system/auth_test.rb` — customer registers, logs in, logs out (Capybara)

---

### T02 · User Roles & RBAC
- [ ] **Task**

  Add `role` enum column to `User` (`customer`, `technician`, `admin`). Default new self-registrations to `customer`. Add helper methods (`admin?`, `technician?`, `customer?`). Add `ApplicationController` before_action `authenticate_user!` and role-guard concern `Authorizable` that raises 403 for wrong-role access.

- **Expected Output**
  - Migration: `add_column :users, :role, :integer, default: 0, null: false`
  - `User` model: `enum role: { customer: 0, technician: 1, admin: 2 }`
  - `app/controllers/concerns/authorizable.rb` with `require_role(*roles)` helper
  - All controllers include `Authorizable`

- **Definition of Done**
  - Accessing an admin-only route as a customer returns 403
  - Role is not mass-assignable from public params
  - Admin account seedable via `db/seeds.rb`

- **Tests**
  - `test/models/user_test.rb` — role enum values; helper methods return correct boolean
  - `test/controllers/concerns/authorizable_test.rb` — wrong role blocked; correct role passes

---

### T03 · Base Layouts & Navigation Per Role
- [ ] **Task**

  Create three scoped layouts (or one layout with conditional nav): `admin`, `technician`, `customer`. Each shows role-appropriate nav links. Set up root route that redirects to role-specific dashboard after login.

- **Expected Output**
  - `app/views/layouts/` — layout partials with role-aware nav
  - `app/controllers/dashboards_controller.rb` — redirects `root_path` to correct dashboard
  - Stimulus controller `app/javascript/controllers/nav_controller.js` for mobile toggle (optional but recommended)

- **Definition of Done**
  - After login, each role lands on their own dashboard
  - Nav links only show routes relevant to that role
  - Unauthenticated root redirects to sign-in

- **Tests**
  - `test/system/navigation_test.rb` — each role sees correct nav after login

---

## Phase 2 — Service Requests

### T04 · ServiceRequest Model
- [ ] **Task**

  Create `ServiceRequest` model with all fields from SR-01 and status state machine. Belongs to `customer` (User) and optionally `technician` (User).

- **Expected Output**
  - Migration with columns:
    - `customer_id:references`
    - `technician_id:bigint` (nullable, not FK-constrained via references to allow null)
    - `device_brand:string, not null`
    - `device_model:string, not null`
    - `serial_number:string`
    - `issue_description:text, not null`
    - `contact_info:string, not null`
    - `status:integer, default: 0, not null`
    - `timestamps`
  - `ServiceRequest` model:
    - `enum status: { submitted: 0, assigned: 1, in_diagnosis: 2, in_repair: 3, completed: 4, cancelled: 5 }`
    - `belongs_to :customer, class_name: "User"`
    - `belongs_to :technician, class_name: "User", optional: true`
    - Validations: presence of `device_brand`, `device_model`, `issue_description`, `contact_info`, `customer`
    - Status transition guard: valid next states enforced

- **Definition of Done**
  - Model persists to DB with correct constraints
  - Invalid status transitions raise or return errors
  - Factory/fixture available for tests

- **Tests**
  - `test/models/service_request_test.rb` — valid record saves; missing required fields fail; status enum values correct; status transition rules enforced; customer association required; technician optional

---

### T05 · Customer: Submit Service Request (SR-01)
- [ ] **Task**

  Build `ServiceRequests` controller `new`/`create` actions scoped to customer role. Form collects device brand, model, serial number, issue description, contact info. On submit, status set to `submitted` automatically.

- **Expected Output**
  - `app/controllers/customer/service_requests_controller.rb` (`new`, `create`)
  - `app/views/customer/service_requests/new.html.erb` — form via `form_with`
  - Route: `namespace :customer { resources :service_requests, only: [:new, :create, :index, :show] }`
  - Flash notice on success; re-render form with errors on failure

- **Definition of Done**
  - Logged-in customer can submit a request and sees it in their list
  - Non-customer role cannot access this route (403)
  - `technician_id` and `status` cannot be set via form params

- **Tests**
  - `test/controllers/customer/service_requests_controller_test.rb` — valid POST creates record with status `submitted`; invalid POST re-renders form; technician/admin blocked
  - `test/system/customer/submit_service_request_test.rb` — end-to-end form submission (Capybara)

---

### T06 · Customer: View Own Service Requests (SR-02, SR-05)
- [ ] **Task**

  `index` lists customer's own requests with status badge. `show` displays full detail including repair notes (visible once `completed`).

- **Expected Output**
  - `app/controllers/customer/service_requests_controller.rb` (`index`, `show`)
  - `app/views/customer/service_requests/index.html.erb` — table with status badge, date, device
  - `app/views/customer/service_requests/show.html.erb` — full detail + repair summary section (conditionally shown when completed)
  - Scope: `current_user.service_requests` — never exposes other customers' records

- **Definition of Done**
  - Customer sees only their own requests
  - Accessing another customer's request ID returns 404
  - Repair notes section hidden until status is `completed`

- **Tests**
  - `test/controllers/customer/service_requests_controller_test.rb` — index scoped to current user; show raises 404 for foreign record
  - `test/system/customer/view_service_requests_test.rb` — list and detail views

---

### T07 · Technician: Assigned Requests Dashboard (SR-06)
- [ ] **Task**

  Technician dashboard lists service requests assigned to them, sorted by `status` priority (in_diagnosis > in_repair > assigned) then by `updated_at` ascending.

- **Expected Output**
  - `app/controllers/technician/service_requests_controller.rb` (`index`, `show`)
  - `app/views/technician/service_requests/index.html.erb` — sorted queue with status badges and last-update time
  - Scope: `current_user.assigned_service_requests` (via `technician_id`)

- **Definition of Done**
  - Only requests assigned to this technician appear
  - Unassigned or other-technician requests are hidden
  - Sort order matches priority spec

- **Tests**
  - `test/controllers/technician/service_requests_controller_test.rb` — only own assigned requests returned; correct sort order

---

### T08 · Technician: Update Status (SR-07)
- [ ] **Task**

  Technician can advance status via a button/dropdown on the service request. Status flow: `assigned → in_diagnosis → in_repair → completed`. No skipping. Use Turbo Streams to update status badge in-place without full page reload.

- **Expected Output**
  - `PATCH /technician/service_requests/:id/status` route
  - `app/controllers/technician/service_requests_controller.rb#update_status`
  - Turbo Stream response updates `status` badge on page
  - Invalid transition returns Turbo Stream with error flash

- **Definition of Done**
  - Technician can only move to valid next state
  - Skipping states (e.g., `assigned → completed`) is rejected
  - Non-technician roles blocked

- **Tests**
  - `test/controllers/technician/service_requests_controller_test.rb` — valid transition succeeds; invalid transition rejected; wrong role blocked

---

### T09 · Technician: Log Diagnosis & Repair Notes (SR-08, SR-09)
- [ ] **Task**

  Create `ServiceNote` model for logging technician findings per service request. Technician can add notes at any time; final completion note is required to mark `completed`.

- **Expected Output**
  - Migration: `ServiceNote` with `service_request_id:references`, `technician_id:references`, `note_type:integer` (enum: `diagnosis`, `repair`, `completion`), `body:text`, `timestamps`
  - `ServiceNote` model: belongs_to `service_request` and `technician` (User); validates presence of `body`
  - `app/controllers/technician/service_notes_controller.rb` (`create`)
  - Notes rendered inline on technician show view; Turbo Stream appends new notes without reload
  - Marking `completed` requires at least one `completion` note

- **Definition of Done**
  - Technician can add notes at any workflow stage
  - Cannot mark complete without a completion note
  - Notes are visible to customer on show page (read-only)

- **Tests**
  - `test/models/service_note_test.rb` — valid note saves; body required; note_type enum correct
  - `test/controllers/technician/service_notes_controller_test.rb` — create adds note; missing body fails; wrong role blocked

---

### T10 · Admin: Service Request Queue (SR-11, SR-14)
- [ ] **Task**

  Admin sees all service requests across all customers, filterable by status and date range. Real-time updates via Turbo Streams broadcast when any request status changes.

- **Expected Output**
  - `app/controllers/admin/service_requests_controller.rb` (`index`, `show`)
  - `app/views/admin/service_requests/index.html.erb` — filterable table (status filter via query param)
  - `ServiceRequest` broadcasts Turbo Stream on `after_update_commit` to `admin_service_requests` channel
  - `app/views/admin/service_requests/_service_request.html.erb` — turbo_stream_from partial

- **Definition of Done**
  - Admin sees every request regardless of customer or technician
  - Status filter narrows list correctly
  - Status updates from technicians reflect in admin view within 1s (WebSocket)

- **Tests**
  - `test/controllers/admin/service_requests_controller_test.rb` — all records returned; filter by status works; non-admin blocked
  - `test/models/service_request_test.rb` — broadcast triggered on status change

---

### T11 · Admin: Assign & Reassign Service Requests (SR-12, SR-13)
- [ ] **Task**

  Admin can assign an unassigned request to a technician, or reassign an already-assigned request to a different technician. Assignment transitions status from `submitted` → `assigned`. Reassignment keeps current status unless reverting.

- **Expected Output**
  - `PATCH /admin/service_requests/:id/assign` route
  - `app/controllers/admin/service_requests_controller.rb#assign`
  - Form: dropdown of active technicians (ordered by current load — count of open assigned requests)
  - Turbo Stream updates technician name and status badge inline

- **Definition of Done**
  - Assigning a `submitted` request changes status to `assigned`
  - Reassigning an in-progress request keeps current status
  - Assigning to a deactivated technician is blocked

- **Tests**
  - `test/controllers/admin/service_requests_controller_test.rb` — assign sets technician_id and status; reassign keeps status; deactivated technician rejected

---

## Phase 3 — User Management

### T12 · Admin: Technician Account Management (UM-01)
- [ ] **Task**

  Admin can create technician accounts (bypassing public signup), edit their profile info, and deactivate (soft-delete via `active` boolean). Deactivated technicians cannot log in and cannot receive new assignments.

- **Expected Output**
  - Migration: `add_column :users, :active, :boolean, default: true, null: false`
  - `app/controllers/admin/users_controller.rb` (`index`, `new`, `create`, `edit`, `update`) — scoped to `role: :technician`
  - `app/views/admin/users/` — list, form views
  - Devise `active_for_authentication?` override returns `false` for inactive users
  - Admin creates technician without requiring email confirmation

- **Definition of Done**
  - Admin can create/edit/deactivate technicians
  - Deactivated technician login attempt redirected with error message
  - Deactivated technician excluded from assignment dropdown (T11)

- **Tests**
  - `test/models/user_test.rb` — `active_for_authentication?` returns false when inactive
  - `test/controllers/admin/users_controller_test.rb` — CRUD operations; deactivated user cannot log in

---

### T13 · Admin: Customer Profiles & Service History (UM-02)
- [ ] **Task**

  Admin can view a list of all customers and drill into any customer's profile showing all their service requests.

- **Expected Output**
  - `app/controllers/admin/customers_controller.rb` (`index`, `show`)
  - `app/views/admin/customers/` — list and profile views
  - `show` lists all service requests for that customer ordered by `created_at desc`

- **Definition of Done**
  - Admin sees all customers
  - Customer detail shows full service request history
  - Customer cannot access this route

- **Tests**
  - `test/controllers/admin/customers_controller_test.rb` — index returns all customers; show lists correct service requests; non-admin blocked

---

## Phase 4 — Messaging

### T14 · Message Model & Scoped Threading (MSG-01, MSG-02)
- [ ] **Task**

  Create `Message` model scoped to a `ServiceRequest`. Both customer (owner) and assigned technician can send messages within that thread.

- **Expected Output**
  - Migration: `Message` with `service_request_id:references`, `sender_id:references` (User), `body:text`, `timestamps`
  - `Message` model: belongs_to `service_request` and `sender` (User); validates presence of `body`; validate sender is customer-owner or assigned-technician of the service_request
  - `app/controllers/messages_controller.rb` (`create`) — accessible by both customer and technician
  - Messages displayed chronologically in service request show view for both roles

- **Definition of Done**
  - Only the customer-owner and the assigned technician can post to a thread
  - Third-party users (other customers, unassigned technicians) cannot post or read the thread
  - Empty body rejected

- **Tests**
  - `test/models/message_test.rb` — valid message saves; empty body fails; unauthorized sender rejected
  - `test/controllers/messages_controller_test.rb` — customer and assigned technician can create; third party blocked

---

### T15 · Real-time Messaging via Action Cable (MSG-03)
- [ ] **Task**

  Wire Action Cable so new messages broadcast instantly to both participants without page reload.

- **Expected Output**
  - `app/channels/service_request_channel.rb` — subscribes to `service_request_#{id}` stream; authenticate via Devise current_user; authorize subscriber is participant
  - `Message` model: `after_create_commit` broadcasts Turbo Stream to stream name
  - `app/javascript/controllers/message_controller.js` — auto-scroll to new message
  - `config/cable.yml` — Redis adapter for dev and prod

- **Definition of Done**
  - Sending a message updates the thread on the receiver's screen within 1s
  - WebSocket connection rejected for non-participants
  - Works in dev (Redis must be running)

- **Tests**
  - `test/channels/service_request_channel_test.rb` — participant subscribes successfully; non-participant subscription rejected; broadcast triggered on message create

---

## Phase 5 — Notifications

### T16 · In-App Status Change Notifications (NTF-01, NTF-02)
- [ ] **Task**

  Create `Notification` model. When service request status changes, create a `Notification` for the relevant user (customer on any status change; technician on new assignment). Display unread count in nav badge; mark as read on view.

- **Expected Output**
  - Migration: `Notification` with `user_id:references`, `service_request_id:references`, `message:string`, `read_at:datetime`, `timestamps`
  - `Notification` model: scope `unread` where `read_at IS NULL`
  - `ServiceRequest` `after_update_commit` callback creates notifications via `NotificationService`
  - `app/controllers/notifications_controller.rb` (`index`, `update` — mark as read)
  - Nav badge shows unread count via Turbo Streams broadcast to user-specific stream

- **Definition of Done**
  - Customer receives notification on every status change
  - Technician receives notification when assigned a new request
  - Unread badge count decrements when notifications are marked read

- **Tests**
  - `test/models/notification_test.rb` — unread scope; `read_at` correctly set
  - `test/services/notification_service_test.rb` — correct notification created for each status transition event

---

### T17 · Email Notifications (NTF-01, NTF-03)
- [ ] **Task**

  Send emails via Action Mailer when: (a) customer's service request status changes, (b) customer receives a new message from technician.

- **Expected Output**
  - `app/mailers/service_request_mailer.rb` — `status_changed(service_request)` and `new_message(message)` methods
  - `app/views/mailers/service_request_mailer/` — HTML + text templates
  - `ServiceRequest` after_update_commit and `Message` after_create_commit enqueue mailer jobs (`deliver_later`)
  - Test env uses `letter_opener` or `test` delivery method; mailer previews in `test/mailers/previews/`

- **Definition of Done**
  - Email sent on status change (customer is recipient)
  - Email sent when technician sends a message (customer is recipient)
  - Emails not sent when customer sends a message or for technician-only events
  - No email sent for cancelled requests after cancellation

- **Tests**
  - `test/mailers/service_request_mailer_test.rb` — correct recipient, subject, body content for each mailer method

---

## Phase 6 — Analytics

### T18 · Admin Analytics Dashboard (RPT-01, RPT-02, RPT-03)
- [ ] **Task**

  Build admin-only analytics page with three report sections: (1) service requests by status and date range, (2) technician performance metrics, (3) device repair trends by brand/model.

- **Expected Output**
  - `app/controllers/admin/analytics_controller.rb` (`index`) — accepts `date_from`, `date_to` query params
  - Report queries:
    - RPT-01: `ServiceRequest.group(:status).where(created_at: range).count`
    - RPT-02: per-technician count of `completed` requests + avg time from `assigned_at` to `completed_at` (requires `assigned_at`, `completed_at` timestamp columns on `ServiceRequest`)
    - RPT-03: `ServiceRequest.group(:device_brand, :device_model).count`
  - Add migration for `assigned_at:datetime` and `completed_at:datetime` columns on `service_requests`
  - `app/views/admin/analytics/index.html.erb` — tables for each report section; date range filter form

- **Definition of Done**
  - All three report tables render with correct data
  - Date range filter narrows RPT-01 results correctly
  - RPT-02 avg resolution time is `null` if any technician has no completed requests
  - Non-admin cannot access analytics route

- **Tests**
  - `test/controllers/admin/analytics_controller_test.rb` — non-admin blocked; date filter returns scoped data
  - `test/models/service_request_test.rb` — `assigned_at` set on assignment; `completed_at` set on completion

---

## Phase 7 — Cross-cutting: Authorization Hardening

### T19 · Server-side Authorization Audit (Security)
- [ ] **Task**

  Audit every controller action to confirm role-guard `before_action` is applied. No action should rely solely on UI-level hiding. Write a checklist-style test that exhaustively attempts cross-role access for every sensitive route.

- **Expected Output**
  - `app/controllers/concerns/authorizable.rb` finalized with `require_admin!`, `require_technician!`, `require_customer!` helpers
  - Every namespaced controller (`admin/*`, `technician/*`, `customer/*`) uses the matching guard
  - `config/routes.rb` namespaced routes reviewed for accidental exposure

- **Definition of Done**
  - Every sensitive route returns 403 when accessed by wrong role
  - No route relies on Devise's `authenticate_user!` alone (role check is separate)

- **Tests**
  - `test/integration/authorization_test.rb` — for each protected route, test: unauthenticated → 302 to login; wrong role → 403; correct role → 200/success

---

## Phase 8 — Seed Data & Final Polish

### T20 · Seeds & Demo Data
- [ ] **Task**

  `db/seeds.rb` creates: 1 admin, 3 technicians, 5 customers, and sample service requests in various statuses with messages and notes. Safe to re-run (idempotent with `find_or_create_by`).

- **Expected Output**
  - `db/seeds.rb` — idempotent seed script
  - `README.md` updated with `rails db:seed` login credentials for demo accounts

- **Definition of Done**
  - `rails db:seed` runs without error on fresh DB
  - Re-running seed does not create duplicates
  - Each role has at least one demo login

- **Tests**
  - Manual verification: `rails db:reset && rails db:seed` runs cleanly in CI

---

## Task Dependency Map

```
T01 (Devise)
 └── T02 (Roles/RBAC)
      └── T03 (Layouts)
           ├── T04 (ServiceRequest model)
           │    ├── T05 (Customer: submit)
           │    ├── T06 (Customer: view)
           │    ├── T07 (Technician: dashboard)
           │    ├── T08 (Technician: status update)
           │    ├── T09 (ServiceNote / repair notes) ── depends on T08
           │    ├── T10 (Admin: queue)
           │    └── T11 (Admin: assign) ── depends on T12
           ├── T12 (Admin: technician management)
           ├── T13 (Admin: customer profiles) ── depends on T04
           ├── T14 (Messages model) ── depends on T04
           │    └── T15 (Action Cable messaging)
           ├── T16 (In-app notifications) ── depends on T04
           ├── T17 (Email notifications) ── depends on T04, T14
           ├── T18 (Analytics) ── depends on T04, T12
           └── T19 (Auth audit) ── depends on all controllers done
T20 (Seeds) ── depends on all models done
```

---

## Running Tests

```bash
rails test                              # all unit + controller tests
rails test:system                       # Capybara/Selenium system tests
rails test test/models/                 # models only
rails test test/controllers/admin/      # admin controllers only
rails test test/integration/            # integration/auth tests
```

> Test env uses SQLite. Never add PostgreSQL-only SQL to migrations — keep queries adapter-agnostic.
