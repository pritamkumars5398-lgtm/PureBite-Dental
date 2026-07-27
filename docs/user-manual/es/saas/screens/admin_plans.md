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

# Planes de Administración SaaS

Permite a los administradores de la plataforma gestionar los planes de precios que se muestran en la página de inicio pública.

## Características

- **Directorio de Planes**: Ver planes activos e inactivos.
- **Crear Plan de Precios**: Agregar nuevos planes indicando la duración en meses, nombre, tarifa y estado activo.
- **Modificar / Retirar Planes**: Actualizar los detalles del plan o desactivarlo para evitar nuevos registros.

## Permisos

| Capacidad | Permiso Requerido |
|-----------|--------------------|
| Gestionar Planes de Precios | `saas.subscriptions.write` |
