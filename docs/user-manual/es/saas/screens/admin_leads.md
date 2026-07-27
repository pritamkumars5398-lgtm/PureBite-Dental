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

# Prospectos de Administración SaaS

Esta página muestra la lista de prospectos e interesados enviados a través de la página de inicio.

## Características

- **Directorio de Prospectos**: Examinar la información de contacto, correo, teléfono y número estimado de usuarios.
- **Gestión del Estado del Prospecto**: Actualizar el estado de cada prospecto (por ejemplo, contactado, pendiente, rechazado).

## Permisos

| Capacidad | Permiso Requerido |
|-----------|--------------------|
| Ver Lista de Prospectos | `saas.leads.read` |
| Actualizar Estado de Prospectos | `saas.leads.write` |
