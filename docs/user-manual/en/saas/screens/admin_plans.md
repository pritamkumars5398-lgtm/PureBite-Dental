---
module: saas
screen: admin_plans
route: /admin/plans
related_endpoints:
  - GET /api/v1/saas/plans
  - POST /api/v1/saas/plans
  - PATCH /api/v1/saas/plans/{plan_id}
  - DELETE /api/v1/saas/plans/{plan_id}
related_permissions:
  - saas.subscriptions.write
related_paths:
  - backend/app/modules/saas/router.py
  - backend/app/modules/saas/frontend/pages/admin/plans.vue
last_verified_commit: 2b470a3
screenshots: []
---

# SaaS Admin Plans

Allows platform administrators to manage pricing plans that are displayed on the public landing page.

## Features

- **Pricing Plans Directory**: View all active and retired pricing plans.
- **Create Pricing Plan**: Create a new plan specifying duration (months), name, price, and active status.
- **Update/Retire Plan**: Modify plan details or retire plans to prevent new signups.

## Permissions

| Capability | Required Permission |
|------------|---------------------|
| Manage Pricing Plans | `saas.subscriptions.write` |
