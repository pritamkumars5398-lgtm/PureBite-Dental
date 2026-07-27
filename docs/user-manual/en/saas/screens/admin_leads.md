---
module: saas
screen: admin_leads
route: /admin/leads
related_endpoints:
  - GET /api/v1/saas/leads
  - PATCH /api/v1/saas/leads/{lead_id}
related_permissions:
  - saas.leads.read
  - saas.leads.write
related_paths:
  - backend/app/modules/saas/router.py
  - backend/app/modules/saas/frontend/pages/admin/leads.vue
last_verified_commit: 2b470a3
screenshots: []
---

# SaaS Admin Leads

This page displays the list of contact leads submitted through the landing page.

## Features

- **Leads Directory**: Browse leads, including organization name, email, phone, and expected user count.
- **Lead Status Management**: Update a lead status (e.g. contacted, pending, rejected).

## Permissions

| Capability | Required Permission |
|------------|---------------------|
| View Leads List | `saas.leads.read` |
| Update Lead Status | `saas.leads.write` |
