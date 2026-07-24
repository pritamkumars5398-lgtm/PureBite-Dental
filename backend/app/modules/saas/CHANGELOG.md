# Changelog — saas module

## Unreleased

- feat(admin): Superadmin dashboard UI — tenant provisioning modal, clinic
  directory with per-clinic subscription-history slideover, grant/renew
  subscription form, and pricing-plan create + activate/retire toggle.
  Previously the backend endpoints existed but the dashboard buttons only
  showed "coming soon" toasts.
- feat(leads): `PATCH /leads/{id}` to mark a lead contacted/processed/
  rejected, wired into the dashboard's leads table. New-lead submissions
  now send a best-effort email notification to every active platform-admin
  user (never blocks lead creation if sending fails).
- feat(landing): public landing page now fetches `GET /plans` and shows
  real Superadmin-managed pricing; falls back to the generic "Get a quote"
  panel when no plans are configured or the fetch fails.
- feat(settings): clinic-facing subscription status card in Settings →
  Clinic Info (status badge, end date, proactive "expires in N days"
  warning at ≤7 days). Hidden for the platform-admin workspace.
- feat(clinics): `GET /clinics` directory endpoint (platform-admin only)
  and `GET /subscriptions?clinic_id=` filter, backing the clinic history
  view.
- fix(subscriptions): `SubscriptionResponse` now reports a computed
  `effective_status` (`upcoming` / `active` / `expired`) derived from
  start/end vs. now — the stored `status` column was always written as
  `"active"` at creation, which misrepresented stacked/future-dated
  renewals.
- fix(datetime): `grant_subscription` used naive `datetime.utcnow()`
  while every other comparison in the module uses timezone-aware
  `datetime.now(timezone.utc)`; unified.
- fix(provisioning): wrap tenant creation commit in a try/except for
  `IntegrityError` → `409` instead of an unhandled 500 on a race.
- fix(subscriptions): `grant_subscription` now 404s on an unknown
  `clinic_id` instead of writing an FK-orphaned subscription row.
- refactor: centralized the "is this the platform-admin clinic" check
  (previously three duplicated `clinic.name == "Platform Administration"`
  string comparisons across `core/auth`) into
  `saas.constants.is_platform_clinic`.
- refactor: extracted `_build_clinic_responses` in `core/auth/router.py`
  to share the per-clinic subscription lookup between `/me` and
  `/refresh` instead of duplicating it.
- chore(frontend): added `PERMISSIONS.saas.*` to
  `frontend/app/config/permissions.ts`; replaced the hardcoded
  `'saas.leads.read'` string literals in `auth.global.ts`, `login.vue`,
  and `useModules.ts`.
