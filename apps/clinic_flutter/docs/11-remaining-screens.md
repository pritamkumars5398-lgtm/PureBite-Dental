# Remaining screens

Inventory of DentalPin **web clinic staff UI** vs this Flutter app. Update this file when a screen moves from placeholder → wired.

**Counts (2026-09-15)**

| Bucket | Total to match web | Shipped in Flutter | Remaining |
|--------|--------------------|--------------------|-----------|
| Shell / auth | 2 | 2 | **0** |
| Main nav | 10 | 4 partial, 6 stubs | **6 to finish** |
| Patient workspace | 8 | 6 tab stubs + header | **tabs need API** |
| Settings categories | 9 | 9 stub landings (not API-backed) | **9 to finish** |
| Settings editor pages | 22 | 11 stub pages wired | **11 leftover + 11 stubs to finish** |
| **Total screens** | **51** | **8 usable** | **~43** |

“Usable” means a staff member can open it and do the primary job (login, browse home/patients/schedule, open settings hub). Empty-state route shells are **not** counted as shipped.

---

## 1. Shell / auth — 0 remaining

| Screen | Route | Status |
|--------|-------|--------|
| Sign in | `/login` | Done (API + Keychain fallback) |
| App chrome (sidebar, top bar, logout) | — | Done (Lucide 20px, web nav set) |

Chart (`/chart`) and Notes (`/notes`) exist as routes but are **not** in the web sidebar. Web puts them on the patient. Keep them as deep links only.

---

## 2. Main nav — 7 remaining

| Screen | Web route | Flutter route | Status |
|--------|-----------|---------------|--------|
| Home | `/` | `/` | Partial — greeting, KPIs, today list, recent patients. Missing timeline strip, overdue API, unconfirmed confirm action |
| Patients | `/patients` | `/patients` | Partial — search + list + basic detail. Missing create modal, filters, debt badge |
| Schedule | `/appointments` | `/appointments` | Partial — day list + week strip. Missing week/day/kanban calendar, create modal |
| Recalls | `/recalls` | `/recalls` | Stub — KPIs + empty state, no API |
| Treatment Plans | `/treatment-plans` | `/treatment-plans` | Stub — filter bar + empty state, no API |
| Quotes | `/budgets` | `/budgets` | Stub — list + detail pane, no API |
| Invoices | `/invoices` | `/invoices` | Stub — list + detail pane, no API |
| Payments | `/payments` | `/payments` | Stub — list + detail pane, no API |
| Reports | `/reports` | `/reports` | Stub — KPI hub + empty state, no API |
| AI | `/copilot` | `/copilot` | Stub — empty chat shell, no API |

**6 stubs** plus **4 partial** main screens. No empty nav shells left.

---

## 3. Patient workspace — tabs stub-wired; API remaining

Web patient is `/patients/:id` with six tabs. Flutter detail now has a sticky header plus those tabs as empty/contact stubs.

| Screen | Status |
|--------|--------|
| Sticky header (call, email, actions) | Stub — name, status, optional actions |
| Summary (plan / next appointment / balance / diagnoses / notes feed) | Stub KPIs |
| Info (demographics, medical, billing, archive) | Partial — phone, email, status |
| Clinical (odontogram diagnosis / plans / appointments / history) | Stub section cards |
| Administration (quotes, invoices, payments, documents) | Stub section cards |
| Gallery | Stub empty state |
| Timeline | Stub empty state |
| Clinical notes composer (API) | Local-only on `/notes` |

---

## 4. Settings — 9 landings stub-wired; 11 editors still missing

Hub `/settings` with 9 categories exists. Each category now opens a Flutter page (no more `comingSoon` hub). These are **stubs**: layout + l10n, not repository/API yet, so they are **not** counted as shipped.

### Category landings (stub, needs API)

General (onboarding + cards), Workspace (cabinets preview), People (current user row), Clinical (catalog empty), Billing, Communications, Integrations, Modules, Account (profile + language cards).

### Editor pages — stub wired (11)

Clinic Information, Branding, Cabinets, Clinic users, Treatment catalog, Billing hub, Notifications, Integrations, Modules, Profile, Language.

### Editor pages still to build (11)

| Category | Pages |
|----------|-------|
| Workspace | Clinic hours, Professional schedules, Data migration |
| Clinical | Recall settings |
| Billing | Subscription, Invoice series, VAT types, Quote expiry, Quote reminders, Public link, Verifactu |

---

## 5. Suggested build order

1. Patients create + detail tabs (Summary / Clinical)
2. Schedule week calendar + create appointment
3. Quotes → Invoices → Payments list+detail (same list-shell pattern)
4. Recalls list + KPIs
5. Treatment plans pipeline
6. Reports hub + overdue home KPI
7. Settings editors starting with Clinic Info, Cabinets, Users, Profile
8. Copilot chat
9. Wire odontogram and notes to the patient Clinical tab; drop them from thinking of them as top-level nav

---

## 6. What “done” means

A screen is **done** when it:

- Uses `AppSpacing` / `AppIcons.md` (Lucide 20) / `AppText` / l10n
- Reads or writes through `ApiConstants` + a repository
- Matches the web primary action (create, filter, or empty CTA)
- Works compact / medium / expanded

Placeholder `ModulePlaceholderPage` routes are **not** done.
