---
module: saas
screen: settings_subscription
route: /settings/billing/subscription
related_endpoints:
  - GET /api/v1/saas/subscriptions
related_permissions:
  - saas.subscriptions.read
related_paths:
  - backend/app/modules/saas/router.py
  - backend/app/modules/saas/frontend/pages/settings/billing/subscription.vue
last_verified_commit: 2b470a3
screenshots: []
---

# Suscripción de la Clínica

Esta página permite a los administradores y miembros de la clínica ver el estado actual de su suscripción y el historial de pagos.

## Características

- **Estado Actual**: Ver si la clínica tiene una suscripción activa, la fecha de vencimiento y los días restantes.
- **Historial de Suscripciones**: Muestra el historial cronológico de los planes de precios contratados por la clínica.

## Permisos

| Capacidad | Permiso Requerido |
|-----------|--------------------|
| Ver Estado e Historial de Suscripción | `saas.subscriptions.read` |
