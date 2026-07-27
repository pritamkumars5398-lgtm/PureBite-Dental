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

# Panel de Control de Administración SaaS

El panel de control central para la administración de la plataforma, que muestra estadísticas generales y controles administrativos.

## Características

- Estadísticas de resumen de clínicas activas, estados de suscripción y prospectos pendientes.
- Enlaces y navegación a planes de precios, directorio de clínicas y solicitudes de contacto.

## Permisos

| Capacidad | Permiso Requerido |
|-----------|--------------------|
| Ver Panel de Administración | `saas.leads.read` |
