---
module: saas
screen: admin_dashboard
route: /admin
related_endpoints:
  - GET /api/v1/saas/leads
  - GET /api/v1/saas/clinics
related_permissions:
  - saas.leads.read
related_paths:
  - backend/app/modules/saas/router.py
  - backend/app/modules/saas/frontend/pages/admin/index.vue
last_verified_commit: 2b470a3
screenshots: []
---

# SaaS Admin Dashboard

The central dashboard for platform administration, displaying high-level statistics and administrative controls.

## Features

- Overview statistics for active clinics, subscription statuses, and pending leads.
- Links and navigation to pricing plans, clinics directory, and incoming lead inquiries.

## Permissions

| Capability | Required Permission |
|------------|---------------------|
| View Admin Dashboard | `saas.leads.read` |
