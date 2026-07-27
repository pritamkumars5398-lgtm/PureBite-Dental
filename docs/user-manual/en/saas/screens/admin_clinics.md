---
module: saas
screen: admin_clinics
route: /admin/clinics
related_endpoints:
  - GET /api/v1/saas/clinics
  - POST /api/v1/saas/clinics/provision
related_permissions:
  - saas.leads.read
  - saas.leads.write
related_paths:
  - backend/app/modules/saas/router.py
  - backend/app/modules/saas/frontend/pages/admin/clinics.vue
last_verified_commit: 2b470a3
screenshots: []
---

# SaaS Admin Clinics

The clinics directory screen allows superadmins to list all registered clinics and provision new clinic tenants.

## Features

- **Clinics Directory**: View active and inactive clinics, along with their tax IDs and creation dates.
- **Tenant Provisioning**: Provision a new clinic tenant by entering the clinic name, tax ID, and administrative user details.

## Permissions

| Capability | Required Permission |
|------------|---------------------|
| View Clinics Directory | `saas.leads.read` |
| Provision New Clinics | `saas.leads.write` |
