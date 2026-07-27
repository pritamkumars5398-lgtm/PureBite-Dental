---
module: saas
last_verified_commit: 2b470a3
---

# SaaS — permissions

Returned by `SaasModule.get_permissions()` (relative names; the permission registry namespaces them as `saas.<name>`).

| Permission | Allows | Required by |
|------------|--------|-------------|
| `saas.leads.read` | View contact leads list and clinic directories. | `GET /api/v1/saas/leads`, `GET /api/v1/saas/clinics` |
| `saas.leads.write` | Update lead statuses and provision new clinic tenants. | `PATCH /api/v1/saas/leads/{lead_id}`, `POST /api/v1/saas/clinics/provision` |
| `saas.subscriptions.read` | View subscription details and pricing plan lists. | `GET /api/v1/saas/subscriptions`, `GET /api/v1/saas/plans` |
| `saas.subscriptions.write` | Create/edit pricing plans and grant/renew tenant subscriptions. | `POST /api/v1/saas/plans`, `PATCH /api/v1/saas/plans/{plan_id}`, `DELETE /api/v1/saas/plans/{plan_id}`, `POST /api/v1/saas/subscriptions` |

## Role assignment

Default role mappings (in `backend/app/modules/saas/__init__.py`):

| Role | SaaS access |
|------|-------------|
| `admin` | All (via `*`). |
| `dentist` | Read subscriptions only (`subscriptions.read`). |
| `hygienist` | None. |
| `assistant` | Read subscriptions only (`subscriptions.read`). |
| `receptionist` | Read subscriptions only (`subscriptions.read`). |

Note: Access to administrative capabilities is further restricted at the request level to users within the `platform-admin` clinic.

## Adding a new permission

1. Add the relative name to `get_permissions()` in `backend/app/modules/saas/__init__.py`.
2. Add a row to the table above.
3. Annotate the endpoint(s) with `Depends(require_permission(...))`.
4. Update `frontend/app/config/permissions.ts` if it gates UI.
