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

# Clínicas de Administración SaaS

La pantalla del directorio de clínicas permite a los superadministradores listar todas las clínicas registradas y aprovisionar nuevos inquilinos de clínicas.

## Características

- **Directorio de Clínicas**: Ver clínicas activas e inactivas, junto con sus identificaciones fiscales y fechas de creación.
- **Aprovisionamiento de Inquilinos**: Registrar y aprovisionar una nueva clínica ingresando el nombre, identificación fiscal e información del administrador.

## Permisos

| Capacidad | Permiso Requerido |
|-----------|--------------------|
| Ver Directorio de Clínicas | `saas.leads.read` |
| Aprovisionar Nuevas Clínicas | `saas.leads.write` |
