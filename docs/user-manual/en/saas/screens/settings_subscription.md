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

# Clinic Subscription Settings

This page allows clinic administrators and members to view their current clinic's subscription status and past billing/subscription history.

## Features

- **Current Status**: View if the current clinic has an active subscription, the expiration date, and the number of days remaining.
- **Subscription History**: View a chronological history of all pricing plans granted/renewed for this clinic.

## Permissions

| Capability | Required Permission |
|------------|---------------------|
| View Subscription Status and History | `saas.subscriptions.read` |
