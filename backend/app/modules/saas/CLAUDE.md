# SaaS platform administration module

Provides platform administration, lead management, pricing plans, and clinic subscription management.

## Public API

- Routes mounted at `/api/v1/saas/`.
- Key endpoints:
  - `POST  /leads`             — submit lead (public)
  - `GET   /leads`             — list leads; permission `leads.read`
  - `PATCH /leads/{lead_id}`   — update lead status; permission `leads.write`
  - `POST  /clinics/provision` — provision new tenant; permission `leads.write`
  - `GET   /clinics`           — list directory of tenants; permission `leads.read`
  - `GET   /plans`             — list active pricing plans (public/admin)
  - `POST  /plans`             — create pricing plan; permission `subscriptions.write`
  - `PATCH /plans/{plan_id}`   — update pricing plan; permission `subscriptions.write`
  - `DELETE /plans/{plan_id}`  — delete pricing plan; permission `subscriptions.write`
  - `GET   /subscriptions`     — list subscriptions; permission `subscriptions.read`
  - `POST  /subscriptions`     — grant/renew subscription; permission `subscriptions.write`

## Dependencies

`manifest.depends = []`

## Permissions

`leads.read`, `leads.write`, `subscriptions.read`, `subscriptions.write`

(Permissions registry namespaces them as `saas.<permission_name>`)

## Tools exposed

None.

## Events emitted

None.

## Events consumed

None.

## Lifecycle

- `installable=True`, `auto_install=True`, `removable=False` from manifest.

## Gotchas / non-obvious invariants

- Access to administrative routes (leads list, plans write, subscription grant, tenant provisioning) is restricted to the platform clinic named `platform-admin`. Callers must verify using the `is_platform_clinic` helper function.
- All non-admin subscription queries must filter by the client's current `clinic_id`.

## Related ADRs

- `docs/adr/0001-modular-plugin-architecture.md`
- `docs/adr/0005-relative-permissions.md`

## CHANGELOG

See `./CHANGELOG.md`.
