# DentalPin — Complete Feature Overview

Comprehensive reference of every feature shipped in DentalPin, organized by functional area. For the auto-generated module catalog see [`docs/modules-catalog.md`](../modules-catalog.md). For architecture decisions see [`docs/adr/`](../adr/).

---

## Platform Foundation

### Multi-Tenancy
Every record in the system is scoped to a `clinic_id`. A single DentalPin instance can host multiple independent clinics with complete data isolation. There is no shared state between clinics.

### Authentication & Sessions
- JWT-based auth with short-lived access tokens and long-lived refresh tokens.
- Login via email + password; token pair refreshed transparently by the frontend.
- Session invalidation on logout; tokens scoped to one clinic membership per user.

### Role-Based Access Control (RBAC)
Five built-in roles with granular, namespaced permissions:

| Role | Default access |
|------|---------------|
| `admin` | Everything (`*`) |
| `dentist` | All clinical features (`clinical.*`) |
| `hygienist` | Patient read + all appointments |
| `assistant` | Patients + appointments (read/write) |
| `receptionist` | Patients + appointments (read/write) |

Permissions follow the pattern `module.resource.action`. Wildcards supported: `*` = all, `module.*` = all in that module. The frontend single source of truth is `frontend/app/config/permissions.ts`.

### Modular Plugin Architecture
DentalPin is composed of independent modules under `backend/app/modules/<name>/`. Each module:
- Declares its own SQLAlchemy models and Alembic migration branch.
- Registers a FastAPI router under `/api/v1/`.
- Publishes and consumes events via the event bus.
- Contributes tools to the AI Copilot registry.
- Can be installed or uninstalled without affecting other modules.

Modules marked `removable=True` can be safely uninstalled; their migration branch rolls back cleanly (see ADR 0002).

### Event Bus
Cross-module communication is entirely event-driven — no direct service-to-service imports across module boundaries. The event bus is synchronous-in-process; handlers are registered at startup from each module's `get_event_handlers()`.

---

## Patient Management

### Patient Records (`patients`)
- Create and manage patient profiles: full name, date of birth, contact info (phone, email, address), national ID (`dni`), gender, preferred language.
- Patient status lifecycle: active → archived. Archived patients are soft-deleted; their clinical data is preserved.
- Global patient search across first name, last name, phone, email, and ID.
- Events published: `patient.created`, `patient.updated`, `patient.archived`.

### Medical History (`patients_clinical`)
- Normalized structured medical history: systemic diseases, surgical history, current medications, allergies (substance + reaction severity).
- Emergency contacts (name, relationship, phone).
- Read/write access controlled independently from base patient data.
- Changes emit `patient.medical_updated` (consumed by the timeline).

### Patient Timeline (`patient_timeline`)
- Unified chronological activity log per patient.
- Aggregates events from 34 event types across all modules: appointments, clinical notes, budgets, invoices, payments, documents, photos, treatment plan changes, medical history updates, email sends/failures, and more.
- Single permission (`patient_timeline.read`) gates the view.
- Read-only — all writes happen through the originating modules.

---

## Clinical Modules

### Dental Chart — Odontogram (`odontogram`)
- Interactive SVG tooth diagram covering the full adult and deciduous dentition.
- Per-tooth and per-surface state recording: caries, restoration, extraction, implant, crown, bridge, furcation, and more.
- Clinical treatments linked to catalog items; tracks status (planned → in-progress → performed).
- Performed treatments trigger `odontogram.treatment.performed`, consumed by budget, payments, and periodontogram modules.

### Periodontal Charting (`periodontogram`) — *optional*
- SEPA-standard periodontal charting with full 6-point probing per tooth.
- Snapshot model: each exam creates an immutable snapshot for longitudinal comparison.
- Recorded indices: probing depth (PD), bleeding on probing (BoP), plaque index (PI), clinical attachment level (CAL).
- Snapshot closed event triggers updates in the patient timeline.
- Manual-install, removable module.

### Clinical Notes (`clinical_notes`)
- Polymorphic note model — four note types sharing a single table:
  - **Administrative** — scheduling notes, patient requests.
  - **Diagnosis** — clinical findings, diagnostic impressions.
  - **Treatment** — per-session procedure records.
  - **Treatment plan** — intent notes attached to a treatment plan.
- Each note records the authoring user and timestamp.
- File attachments delegated to the `media` module.

### Treatment Plans (`treatment_plan`)
- Create structured multi-phase treatment plans composed of catalog items linked to odontogram teeth.
- Status lifecycle: `draft` → `confirmed` → `in_progress` → `closed` (or `reactivated`).
- Per-item session tracking: each catalog item can span multiple appointment sessions; the plan marks completion on the last session.
- Automatic two-way sync with budgets: adding/removing plan items publishes events that update the linked budget line items.
- Emits 11 event types covering every lifecycle transition, consumed by budget, payments, recalls, and the timeline.

---

## Scheduling

### Appointment Agenda (`agenda`)
- Create, update, and cancel appointments linked to a patient, cabinet, professional, and catalog item.
- Weekly and kanban (by-cabinet) calendar views.
- Appointment status machine: `scheduled` → `confirmed` → `checked_in` → `in_treatment` → `completed` / `no_show` / `cancelled`.
- Visit notes editable per appointment, independent of clinical notes.
- Cabinet management: define treatment rooms with names and display colors.
- Conflict detection: the backend validates overlaps before confirming a booking.

### Operating Schedules (`schedules`) — *optional, removable*
- Define clinic-level operating hours (open/close per weekday).
- Per-professional working schedules with exception overrides (days off, extended hours, etc.).
- Availability query API: given a time range and duration, returns free slots for a professional.
- Occupancy analytics: appointment fill-rate, idle time, and utilization by cabinet or professional.
- Listens to `appointment.scheduled`, `appointment.updated`, `appointment.cancelled` to keep occupancy statistics up to date.

### Patient Recalls (`recalls`) — *optional, removable*
- Schedule a future call-back for a patient (reason, target date, assigned user).
- Monthly call list view: surface all recalls due this month, work through them inline.
- Log contact attempts per recall (date, outcome, free-text note).
- Auto-links a recall to a booked appointment when a matching `appointment.scheduled` event fires.
- Listens to `appointment.completed` and `treatment_plan.treatment_completed` to auto-close recalls.
- Listens to `patient.archived` to cancel open recalls.

---

## Financial Management

### Treatment Catalog (`catalog`)
- Clinic-specific catalog of dental treatments with: code, name (ES/EN), base price, VAT type, category.
- VAT type definitions (e.g., 0%, reduced, standard) stored separately and referenced by line items.
- Admin-only write access; read access for all clinical roles.

### Budgets / Estimates (`budget`)
- Create treatment quotes composed of catalog line items, optionally linked to odontogram teeth.
- Versioning: renegotiated budgets create a new version while preserving history.
- Status machine: `draft` → `sent` → `pending_acceptance` → `accepted` / `rejected` / `expired`.
- Patient-facing link for digital acceptance (see ADR 0006 for 2-factor guard on the public link).
- PDF generation for sharing.
- Emits 7 events: `budget.sent`, `budget.viewed`, `budget.accepted`, `budget.rejected`, `budget.expired`, `budget.renegotiated`, `budget.reminder_sent`.

### Payments (`payments`)
- Patient-centric payment collection independent of individual invoices.
- Payment allocation: a payment can be split across multiple budgets or held on-account.
- Supported payment methods configurable per clinic.
- Refund workflow with audit trail.
- Patient ledger: running balance of all payments vs. invoiced amounts.
- Payment reports per date range, professional, or payment method.

### Billing / Invoices (`billing`)
- Generate invoices from accepted budgets or as standalone documents.
- Automatic sequential invoice numbering per clinic.
- Credit notes (corrective invoices) for cancellations or adjustments.
- PDF export for printing or email.
- Emits `invoice.issued`, `invoice.paid`, `invoice.sent`.

### Veri*Factu Compliance (`verifactu`) — *optional, Spain only*
- AEAT Veri*Factu electronic invoicing compliance for Spanish clinics.
- Queue-based submission of invoice records to the tax authority.
- Environment promotion (sandbox → production) with confirmation guard.
- Separate permission set so compliance staff can manage queues without full billing admin rights.
- Manual-install, removable module.

---

## Media & Documents

### Media Library (`media`)
- Upload and manage patient files: clinical photos, X-rays (DICOM-compatible naming), PDFs, and arbitrary documents.
- Polymorphic attachment registry: any file can be linked to a clinical note, appointment, treatment plan item, or other entity via a generic attachment record (see ADR 0007).
- Photo pairing: before/after photo pairs for clinical galleries.
- Emits `document.uploaded`, `media.photo_uploaded`, `media.pair_created`, and corresponding removal events.
- Listens to `patient.archived` to mark media as archived.

---

## Communication

### Notifications (`notifications`)
- Event-driven email sending: reacts to events from other modules to trigger templated emails.
- Triggers covered out of the box:
  - Appointment scheduled/cancelled → confirmation/cancellation email to patient.
  - Budget sent → budget link email to patient.
  - Budget accepted → notification to the clinic.
  - Invoice sent → invoice email with PDF attachment.
  - Patient created → welcome email.
- Per-patient and per-clinic notification preferences (opt-out per category).
- Customizable HTML email templates per event type, editable from the admin UI.
- SMTP configuration per clinic (host, port, TLS, credentials).
- Notification send log with status, timestamp, and error details.

---

## AI Copilot (`copilot`) — *optional, removable*

A built-in agentic AI assistant that turns the clinic into something staff can simply talk to.

### Core capabilities
- **Natural language interface** in Spanish and English.
- **Multi-step task planning**: the agent decomposes complex requests into tool calls and executes them in sequence.
- **Real operations**: calls the same backend services the UI does — not a read-only chatbot.

### Safety & compliance
- **RBAC parity**: every tool call is re-authorized against the calling user's permissions at the execution chokepoint. The Copilot can only do what that user can do through the UI.
- **PHI redaction**: patient names, phones, emails, IDs, and other identifiers are tokenized before any text reaches the LLM provider. Free-text clinical fields are excluded from the cloud path entirely. Enabled by default.
- **Confirmed writes**: any action that mutates data (booking an appointment, recording a payment, editing a patient) pauses mid-conversation for explicit user confirmation.

### Built-in workflows (playbooks)
One-tap guided flows for common multi-step jobs:
- **Daily briefing** — today's schedule, due recalls, open budgets.
- **Prepare a visit** — patient summary before an appointment.
- **Fill a gap** — suggest patients to call for a free slot.
- **Due recalls** — surface and work through overdue call-backs.
- **Unanswered budgets** — chase pending acceptance from patients.

### Proactive digest
- Opt-in morning email digest summarizing the day's appointments, due recalls, and open budgets.
- Fully deterministic — no LLM involved, no PHI leaves the server.

### Architecture
- Vendor-agnostic LLM abstraction: provider, model, and per-clinic token budget are configurable per deployment.
- Tool registry: each module contributes its own Copilot tools via `get_tools()`. The Copilot gains new capabilities automatically when new modules are installed.
- Conversation history stored per user with admin supervision access.
- See [`docs/technical/copilot-agentic-architecture.md`](../technical/copilot-agentic-architecture.md) for full architecture.

---

## Data Migration

### Migration Import (`migration_import`) — *optional, manual install*
- Imports clinic data from `.dpmf` binary packages generated by `dental-bridge` (the migration bridge tool).
- Covers: patients, medical history, clinical notes, appointments, schedules, recalls, catalog, budgets, odontogram, treatment plans, billing, payments, and media.
- Job-based architecture: upload → resolve → execute → completed/failed with progress events.
- Idempotent: re-running a job on the same source does not duplicate data.
- Admin-only permissions; removable after migration is complete.

---

## Reporting

### Reports (`reports`)
Cross-module reporting dashboard with three report categories:

| Report | What it shows |
|--------|--------------|
| **Billing** | Revenue by period, payment method breakdown, invoice status summary |
| **Budgets** | Funnel: sent → accepted → invoiced; average budget value; rejection reasons |
| **Scheduling** | Appointment volume, cancellation rate, no-show rate, occupancy by professional |

All reports are filtered by date range and scoped to the caller's clinic.

---

## Developer & Operator Features

### REST API
- OpenAPI 3.0 spec auto-generated by FastAPI; accessible at `/docs` (Swagger UI) and `/redoc`.
- Consistent response envelopes: `ApiResponse<T>` for single items, `PaginatedApiResponse<T>` for lists.
- Standard status codes across all endpoints (200/201/204/400/401/403/404/409/422).

### Database
- PostgreSQL 15 with `asyncpg` driver.
- UUID primary keys, `TIMESTAMPTZ` timestamps, `JSONB` for flexible fields.
- Soft-delete via `status` column — patient data is never hard-deleted.
- Per-module Alembic migration branches; `alembic upgrade heads` applies all module migrations.

### Testing
- Backend: `pytest` + `pytest-asyncio` with `db_session`, `client`, and `auth_headers` fixtures.
- Frontend unit: `vitest`.
- E2E: Playwright against the full stack (`localhost:3000` → `:8000`); covers navigation, RBAC, and patient detail smoke tests.
- CI: ruff lint + format check, migration drift check, docs layout check.

### Demo Environment
```bash
docker-compose up -d
./scripts/seed-demo.sh          # English (default)
./scripts/seed-demo.sh --lang es  # Spanish
```

Demo accounts (password: `demo1234`):

| Email | Role |
|-------|------|
| admin@demo.clinic | admin |
| dentist@demo.clinic | dentist |
| hygienist@demo.clinic | hygienist |
| assistant@demo.clinic | assistant |
| receptionist@demo.clinic | receptionist |

---

## Localization

- UI strings in **Spanish** (primary) with full English translation.
- Backend code, API fields, and documentation in English.
- Seed data available in both locales.
- Architecture supports additional locales via Nuxt i18n layers.

---

## License

Business Source License 1.1 (BSL 1.1). Converts to Apache 2.0 four years from the release date. Commercial SaaS use restricted until conversion. See [LICENSE](../../LICENSE).

---

## Competitive Gap Analysis

Feature comparison against leading Australian dental practice management software: Dental4Windows, Dental4Web, Praktika, Exact Dental, Dentally, Zavy360, and Ultimo. Analysis based on public marketing pages as of June 2026.

### 🔴 High Priority — Core gaps present in every competitor

| Missing Feature | Competitors that have it | Notes |
|---|---|---|
| **Online patient self-booking** | Dental4Windows, Dental4Web, Praktika, Dentally, Zavy360, Exact Dental | Patients book via public link or widget; deposit collection at booking time (Dental4Windows) |
| **Patient portal / mobile app** | Zavy360 (Zavy Connect), Exact Dental, Dentally | Patients view treatment plans, sign consents, pay bills, access documents, fill forms |
| **Digital eForms / paperless check-in** | Dental4Windows (eForms + eKiosk), Praktika, Exact Dental (Clinipad), Dentally | Electronic intake forms completed before the visit; iPad kiosk self-arrival |
| **SMS / WhatsApp appointment reminders** | Dental4Windows, Praktika, Dentally, Zavy360 | Automated reminder messages N days before appointment; DentalPin sends email only |
| **Waitlist management** | Dentally (short-notice filler), Zavy360 | Patients opt into a cancellation list; system fills gaps automatically |
| **Health fund / insurance claims** | Praktika (HICAPS + Tyro), Dentally (Medicare + HICAPS) | Direct claim submission to health funds; critical for Australian market adoption |

### 🟠 Medium Priority — Differentiators that drive growth

| Missing Feature | Competitors that have it | Notes |
|---|---|---|
| **Digital X-ray / DICOM imaging integration** | All 7 competitors | Connect to imaging hardware; view, annotate, and store radiographs inside the patient chart |
| **AI-powered diagnostic imaging** | Dentally (AI detection), Exact Dental (Second Opinion AI) | AI flags caries, bone loss, and pathology in X-rays at time of capture |
| **Patient deposit on booking** | Dental4Windows | Collect payment at time of online booking to reduce no-shows |
| **Buy Now Pay Later / treatment financing** | Dental4Windows (National Dental Plan) | Patient financing options at point of treatment acceptance |
| **Lapsed patient tracking / CRM** | Exact Dental, Zavy360 | Auto-identify patients not seen in X months; targeted re-engagement |
| **Patient review / reputation management** | Exact Dental (Customer Radar), Zavy360 | Collect Google reviews post-appointment; build public reputation |
| **Referral management** | Praktika | Track inbound/outbound referrals between GPs, specialists, and patients |
| **Multi-site / group practice (DSO) view** | Dental4Web, Exact Dental, Zavy360, Ultimo | Consolidated reporting and management across multiple clinic locations; DentalPin is multi-tenant but each clinic is isolated with no group hierarchy |

### 🟡 Lower Priority — Operational and market-specific extras

| Missing Feature | Competitors that have it | Notes |
|---|---|---|
| **Sterilisation / autoclave tracking** | Praktika | Log instrument cycles, tray IDs, batch numbers for infection control compliance |
| **Inventory / stock management** | Zavy360 (integration), Praktika | Track consumables and supplies; reorder alerts |
| **Accounting software integration** | Dental4Windows (Xero) | Sync invoices and payments to Xero / MYOB |
| **Automated marketing campaigns** | Dental4Windows, Exact Dental (Campaign Plus) | Target patient segments (e.g. no appointment in 12 months) with email/SMS blasts |
| **Patient education content** | Dentally | Visual treatment explainers to improve case acceptance rates |
| **Staff / team KPI dashboard** | Exact Dental (Dentist Portal), Dental4Web | Per-dentist production, hours, appointment completion rate |
| **On-premise / hybrid deployment** | Dental4Windows (on-prem), Ultimo (hybrid cloud) | For clinics with data sovereignty or connectivity constraints |
| **Third-party integration marketplace** | Dental4Windows (HotDoc, HealthEngine, Pearl, Kiroku, Xero), Dentally, Praktika | Named connectors to booking aggregators, AI tools, and accounting systems |
| **Real-time practice KPI dashboard** | Exact Dental (MyPractice Cloud), Dental4Web, Zavy360 | Live metrics (chair utilization, revenue today, no-show rate) from any device |

### Recommended build order

Based on frequency across competitors and impact on clinic adoption:

1. **SMS appointment reminders** — directly reduces no-shows; present in every competitor; low architectural complexity (add SMS provider alongside existing email notifications module).
2. **Online patient self-booking** — removes the #1 receptionist workload and is expected by patients; requires a public-facing booking widget and slot availability API.
3. **Digital eForms / electronic check-in** — eliminates paper; speeds up reception; pairs naturally with the patient portal.
4. **Patient portal** — unlocks online payments, plan signing, and document access; Zavy360's patient app is the strongest reference implementation.
5. **HICAPS / health fund claims** — without this, Australian clinics cannot switch from incumbent software; required for AU market entry.
