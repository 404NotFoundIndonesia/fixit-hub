# Product Requirements Document (PRD)

## FixIT Hub

**Version**: 1.0  
**Date**: 2026-05-13  
**Status**: Draft

---

## 1. Overview

FixIT Hub is a web-based service management platform for HP and laptop repair operations. It centralizes service request lifecycle management — from submission by customers to diagnosis and resolution by technicians — under a single platform monitored by administrators.

---

## 2. Goals

| Goal | Description |
|------|-------------|
| Efficient Service Management | Streamline intake, assignment, and resolution of device repair requests |
| Customer Transparency | Give customers real-time visibility into their service request status |
| Technician Productivity | Provide technicians structured tools for diagnosis, repair logging, and task management |
| Data Insights | Surface analytics on service performance, technician workload, and device trends |

---

## 3. User Roles

### 3.1 Customer
End users who own devices needing service. Interact through a self-service portal.

### 3.2 Technician
Service staff who diagnose and repair devices. Work from an assigned task queue.

### 3.3 Admin
Platform operators who manage users, assign service requests, and monitor overall performance.

---

## 4. Functional Requirements

### 4.1 Authentication & Authorization

- Users register and log in via email/password (Devise)
- Role-based access control: each role sees only its own views and actions
- Admin can create/edit/deactivate technician accounts
- Customers self-register

### 4.2 Service Request Management

#### Customer

| # | Requirement |
|---|-------------|
| SR-01 | Submit a service request with device brand, model, serial number, issue description, and contact info |
| SR-02 | View list of own service requests with current status |
| SR-03 | Receive status change notifications (in-app and/or email) |
| SR-04 | Communicate with assigned technician via integrated messaging |
| SR-05 | View repair notes and completion summary upon resolution |

#### Technician

| # | Requirement |
|---|-------------|
| SR-06 | View dashboard of assigned service requests, sorted by priority |
| SR-07 | Update service request status (Pending → In Diagnosis → In Repair → Completed) |
| SR-08 | Log diagnosis findings and repair steps per service request |
| SR-09 | Mark service request as completed with final repair notes |
| SR-10 | Communicate with customer via integrated messaging |

#### Admin

| # | Requirement |
|---|-------------|
| SR-11 | View all incoming service requests in a queue |
| SR-12 | Assign service requests to technicians based on workload and expertise |
| SR-13 | Reassign service requests between technicians |
| SR-14 | Monitor real-time status of all active service requests |

### 4.3 User Management (Admin)

| # | Requirement |
|---|-------------|
| UM-01 | Create, edit, and deactivate technician accounts |
| UM-02 | View customer profiles and their service history |
| UM-03 | Manage system-wide settings |

### 4.4 Messaging

| # | Requirement |
|---|-------------|
| MSG-01 | Customers and their assigned technician can exchange messages within a service request thread |
| MSG-02 | Messages are scoped per service request |
| MSG-03 | Real-time delivery via Action Cable |

### 4.5 Notifications

| # | Requirement |
|---|-------------|
| NTF-01 | Customer notified when service request status changes |
| NTF-02 | Technician notified when a new service request is assigned |
| NTF-03 | Customer notified when technician sends a message |

### 4.6 Analytics & Reporting (Admin)

| # | Requirement |
|---|-------------|
| RPT-01 | Report on service requests by status, date range, and technician |
| RPT-02 | Technician performance metrics (requests completed, avg. resolution time) |
| RPT-03 | Device repair trends by brand/model |
| RPT-04 | Customer satisfaction indicators |

---

## 5. Service Request Status Flow

```
Submitted → Assigned → In Diagnosis → In Repair → Completed
                                                 ↘ Cancelled
```

- **Submitted**: Customer submitted; not yet assigned to a technician
- **Assigned**: Admin assigned to a technician
- **In Diagnosis**: Technician actively diagnosing the device
- **In Repair**: Repair in progress
- **Completed**: Repair done; customer notified
- **Cancelled**: Request cancelled by customer or admin

---

## 6. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| Performance | Page loads under 2s for standard operations |
| Real-time | Messaging and status updates delivered in under 1s via WebSocket (Action Cable + Redis) |
| Security | Role-based access enforced server-side on every request |
| Scalability | Stateless Rails app; database and Redis externalized for horizontal scaling |
| Browser Support | Modern evergreen browsers (Chrome, Firefox, Safari, Edge) |

---

## 7. Technical Constraints

- **Framework**: Ruby on Rails 7.0.8, Ruby 3.0.2
- **Database**: PostgreSQL (production/development), SQLite (test)
- **Frontend**: Hotwire (Turbo + Stimulus), no separate SPA framework
- **Authentication**: Devise
- **Real-time**: Action Cable over Redis
- **Asset pipeline**: Sprockets + importmap (no Node.js/webpack build step)

---

## 8. Out of Scope (v1.0)

- Mobile native apps (iOS/Android)
- Payment processing or invoicing
- Inventory/parts management
- SLA tracking and automated escalations
- Third-party device warranty API integrations
- Multi-branch / multi-location support
