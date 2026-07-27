---
module: saas
last_verified_commit: 2b470a3
---

# SaaS — technical overview

Owns the platform-level administration capabilities, including lead capture/management, clinic tenant provisioning, pricing plans, and clinic subscription lifecycle management.

## Models

- `SaasLead` — captures info for prospective clinics submitted via the public landing page.
- `SaasPricingPlan` — defines available subscription packages (price, duration in months).
- `SaasSubscription` — links a clinic to a pricing plan with a concrete start/end range. Supports stacking (future-dated upcoming subscriptions).

Source: `backend/app/modules/saas/models.py`.

## Services

Router is thin and directly executes queries/commits via `db: AsyncSession` inside the endpoints. Key multi-tenancy and logic checks are inline in `backend/app/modules/saas/router.py`.

## Multi-tenancy

- Most write and administrative operations are gated by `is_platform_clinic(ctx.clinic.name)`, restricting access strictly to the platform administration clinic.
- Subscriptions are queried securely: non-platform users are restricted to viewing only their own clinic's subscriptions (`clinic_id == ctx.clinic_id`).

## Frontend

Nuxt layer at `backend/app/modules/saas/frontend/`.
Pages:
- `pages/admin/index.vue` → `/admin` (dashboard). Documented in [`user-manual/en/saas/screens/admin_dashboard.md`](../../user-manual/en/saas/screens/admin_dashboard.md).
- `pages/admin/clinics.vue` → `/admin/clinics` (clinics list). Documented in [`user-manual/en/saas/screens/admin_clinics.md`](../../user-manual/en/saas/screens/admin_clinics.md).
- `pages/admin/leads.vue` → `/admin/leads` (leads list). Documented in [`user-manual/en/saas/screens/admin_leads.md`](../../user-manual/en/saas/screens/admin_leads.md).
- `pages/admin/plans.vue` → `/admin/plans` (pricing plans list). Documented in [`user-manual/en/saas/screens/admin_plans.md`](../../user-manual/en/saas/screens/admin_plans.md).
- `pages/settings/billing/subscription.vue` → `/settings/billing/subscription` (settings subscription). Documented in [`user-manual/en/saas/screens/settings_subscription.md`](../../user-manual/en/saas/screens/settings_subscription.md).

## Lifecycle

`installable=True`, `auto_install=True`, `removable=False`. The SaaS administration module is a core part of the multi-tenant platform.

## Related ADRs

- [`0001` — modular plugin architecture](../../adr/0001-modular-plugin-architecture.md)
- [`0005` — relative permissions](../../adr/0005-relative-permissions.md)

## See also

- [Permissions](./permissions.md) — `leads.read`, `leads.write`, `subscriptions.read`, `subscriptions.write`.
- Module CLAUDE notes: [`backend/app/modules/saas/CLAUDE.md`](../../../backend/app/modules/saas/CLAUDE.md).
