# DentalPin — Feature Status

Quick reference: what DentalPin has today vs. what is missing compared to leading dental practice management software (Dental4Windows, Dental4Web, Praktika, Exact Dental, Dentally, Zavy360, Ultimo). Analysis based on June 2026 competitor review.

---

## ✅ Features We Have

### Patient Management
- [x] Patient profiles — name, DOB, contact info, national ID, gender, status
- [x] Patient search — by name, phone, email, ID
- [x] Patient archive (soft-delete, data preserved)
- [x] Medical history — diseases, medications, allergies, surgical history
- [x] Emergency contacts
- [x] Patient timeline — unified chronological activity log

### Clinical
- [x] Interactive odontogram (dental chart) — per-tooth and per-surface states
- [x] Periodontal charting (SEPA standard) — probing depth, BoP, PI, CAL, snapshots
- [x] Clinical notes — administrative, diagnosis, treatment, plan (polymorphic)
- [x] Treatment plans — multi-phase, per-item session tracking, lifecycle management
- [x] Treatment plan ↔ budget two-way sync
- [x] Treatment plan ↔ odontogram sync

### Scheduling
- [x] Appointment calendar — weekly and kanban (by-cabinet) views
- [x] Appointment status machine — scheduled → confirmed → checked-in → in-treatment → completed / no-show / cancelled
- [x] Cabinet / treatment room management
- [x] Conflict detection on booking
- [x] Professional operating schedules and overrides
- [x] Slot availability API
- [x] Occupancy analytics (fill rate, idle time, utilization)
- [x] Patient recalls — call-back scheduling, monthly call list, attempt logging, auto-link on booking

### Financial
- [x] Treatment catalog — codes, prices, VAT types, categories
- [x] Budgets / treatment estimates — versioning, renegotiation, digital acceptance link, PDF
- [x] Budget status machine — draft → sent → pending → accepted / rejected / expired
- [x] Invoice generation from budgets or standalone
- [x] Sequential invoice numbering
- [x] Credit notes / corrective invoices
- [x] Invoice PDF export
- [x] Patient payments — collection, allocation to budgets, on-account balance
- [x] Refunds with audit trail
- [x] Patient ledger (running balance)
- [x] Payment reports by date, professional, method
- [x] Veri*Factu tax compliance (Spain / AEAT) *(optional module)*

### Media & Documents
- [x] File uploads — photos, X-rays, PDFs, arbitrary documents
- [x] Polymorphic attachments — link any file to a note, appointment, plan item, etc.
- [x] Before/after clinical photo pairs
- [x] Media archived when patient is archived

### Communication
- [x] Email notifications — appointment confirmed/cancelled, budget sent/accepted, invoice sent, patient welcome
- [x] Customizable email templates per event
- [x] Per-patient and per-clinic notification preferences (opt-out)
- [x] SMTP configuration per clinic
- [x] Notification send log with status and error details

### AI Copilot
- [x] Conversational AI agent — Spanish and English
- [x] Multi-step task planning and execution (real operations, not read-only)
- [x] RBAC parity — every tool call re-authorized at execution
- [x] PHI redaction before LLM (names, phones, emails, IDs tokenized)
- [x] Confirmed writes — mutations pause for explicit user confirmation
- [x] Built-in playbooks — daily briefing, prepare a visit, fill a gap, due recalls, unanswered budgets
- [x] Proactive morning digest email (deterministic, no LLM, no PHI off-site)
- [x] Vendor-agnostic LLM abstraction — configurable provider, model, token budget
- [x] Conversation history with admin supervision

### Reporting
- [x] Billing reports — revenue by period, payment method breakdown, invoice status
- [x] Budget funnel reports — sent → accepted → invoiced, average value, rejection reasons
- [x] Scheduling reports — appointment volume, cancellation rate, no-show rate, occupancy

### Platform
- [x] Multi-tenancy — full data isolation per clinic on a shared instance
- [x] Role-based access control — admin, dentist, hygienist, assistant, receptionist
- [x] Granular namespaced permissions per module
- [x] JWT auth with access + refresh tokens
- [x] Modular plugin architecture — install / uninstall modules independently
- [x] Event bus — cross-module communication without direct imports
- [x] Per-module Alembic migration branches (safe uninstall)
- [x] REST API with OpenAPI docs
- [x] Data migration import from `.dpmf` packages (dental-bridge) *(optional module)*
- [x] Docker Compose deployment
- [x] Bilingual UI — Spanish (primary) + English

---

## ❌ Features We Are Missing

### 🔴 High Priority — Core gaps, every competitor has these

| Feature | What it means | Best competitor example |
|---|---|---|
| **Online patient self-booking** | Patients book appointments via a public link or embeddable widget, 24/7, without calling the clinic | Dental4Windows, Dentally, Zavy360 |
| **Patient portal / mobile app** | Patients log in to view treatment plans, sign consents, pay bills, download documents, fill forms | Zavy360 (Zavy Connect app), Exact Dental, Dentally |
| **Digital eForms / electronic check-in** | Patients complete intake and medical history forms electronically before arrival; iPad kiosk for self-arrival | Dental4Windows (eForms + eKiosk), Exact Dental (Clinipad), Dentally |
| **SMS appointment reminders** | Automated text messages sent N days/hours before appointment; DentalPin only sends email | Praktika, Dentally, Zavy360, Dental4Windows |
| **Waitlist / short-notice filler** | Patients opt into a cancellation list; system automatically contacts them when a slot opens | Dentally, Zavy360 |
| **Health fund / insurance claims** | Direct HICAPS, Medicare, Tyro claim submission at point of payment | Praktika (HICAPS + Tyro), Dentally (Medicare + HICAPS) |

### 🟠 Medium Priority — Present in 2–4 competitors, meaningful differentiators

| Feature | What it means | Best competitor example |
|---|---|---|
| **Digital X-ray / DICOM viewer** | Connect to imaging hardware; view, annotate, and store radiographs inside the patient chart | All 7 competitors |
| **AI diagnostic imaging** | AI automatically flags caries, bone loss, and pathology in X-rays at time of capture | Dentally (AI detection), Exact Dental (Second Opinion AI) |
| **Deposit on booking** | Collect a payment at the time of online self-booking to reduce no-shows | Dental4Windows |
| **Buy Now Pay Later / treatment financing** | Offer patient payment plans at point of treatment acceptance | Dental4Windows (National Dental Plan) |
| **Lapsed patient tracking / CRM** | Auto-identify patients not seen in X months and surface them for re-engagement | Exact Dental, Zavy360 |
| **Patient review management** | Prompt patients to leave a Google review post-appointment; monitor and respond to reviews | Exact Dental (Customer Radar), Zavy360 |
| **Referral management** | Track and communicate inbound/outbound referrals (GP → specialist → patient) | Praktika |
| **Multi-site / DSO group view** | Consolidated reporting and management across multiple clinic locations under one owner | Dental4Web, Exact Dental, Zavy360, Ultimo |

### 🟡 Low Priority — Niche or operational extras

| Feature | What it means | Best competitor example |
|---|---|---|
| **Sterilisation / autoclave tracking** | Log instrument cycles, tray IDs, batch numbers for infection control compliance | Praktika |
| **Inventory / stock management** | Track dental consumables and supplies; reorder alerts | Zavy360, Praktika |
| **Accounting software integration** | Sync invoices and payments to Xero or MYOB | Dental4Windows (Xero) |
| **Automated marketing campaigns** | Target patient segments (e.g. no visit in 12 months) with scheduled email/SMS blasts | Dental4Windows, Exact Dental (Campaign Plus) |
| **Patient education content** | Visual explainers of treatments shown to patients to improve case acceptance | Dentally |
| **Staff / team KPI dashboard** | Per-dentist production, hours, and appointment completion rates | Exact Dental (Dentist Portal), Dental4Web |
| **On-premise / hybrid deployment** | For clinics with data sovereignty or unreliable connectivity requirements | Dental4Windows (on-prem), Ultimo (hybrid cloud) |
| **Third-party integration marketplace** | Named connectors to HotDoc, HealthEngine, Pearl AI, Kiroku, Xero, etc. | Dental4Windows, Dentally, Praktika |
| **Real-time practice KPI dashboard** | Live metrics (chair utilization, daily revenue, no-show rate) accessible from any device | Exact Dental (MyPractice Cloud), Zavy360 |

---

## Gap Summary

```
Area                        Status
─────────────────────────────────────────────────────
Patient self-service        ❌ No booking, no portal, no eForms, no deposits
SMS communication           ❌ Email only — no SMS / WhatsApp
Digital imaging             ❌ Upload only — no DICOM viewer, no AI detection
Health fund claims          ❌ No HICAPS / Medicare / Tyro
Group / DSO management      ❌ No multi-site consolidated view
CRM / retention             ⚠️  Recalls exist — lapsed patient CRM missing
Treatment financing         ❌ No BNPL or payment plan option
Reputation management       ❌ No review collection or monitoring
Referrals                   ❌ Not tracked
Inventory                   ❌ Not managed
Accounting integration      ❌ No Xero / MYOB sync
Marketing automation        ❌ No campaign builder
Sterilisation tracking      ❌ Not present
Reporting                   ⚠️  Module reports exist — no real-time live KPIs
AI Copilot                  ✅ Ahead of all competitors
Multi-tenancy / RBAC        ✅ Solid
Modular architecture        ✅ Ahead of all competitors
Clinical charting           ✅ Odontogram + periodontogram covered
Treatment & billing         ✅ Full lifecycle covered
```

---

## Recommended Build Order

| # | Feature | Why first |
|---|---|---|
| 1 | **SMS appointment reminders** | Lowest complexity, highest immediate impact on no-show rate; extends the existing notifications module |
| 2 | **Online patient self-booking** | Removes the #1 receptionist workload; expected by patients; requires public slot availability API |
| 3 | **Digital eForms** | Eliminates paper; pairs with self-booking for a fully contactless pre-arrival flow |
| 4 | **Patient portal** | Unlocks online payments, plan signing, and document access; Zavy360's app is the strongest reference |
| 5 | **HICAPS / health fund claims** | Without it, Australian clinics cannot switch from incumbents — the single biggest adoption blocker for AU market |
