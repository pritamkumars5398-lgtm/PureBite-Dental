# Offline sync

After first login + sync, clinical MVP works with **no network**: patients, appointments, odontogram, notes.

## Rules

1. **UI reads Drift only.** Never bind a list to a live HTTP future.
2. **Writes** go to Drift first, then an **outbox** row, then flush when online.
3. **Pull** when connectivity returns and on shell resume.
4. Show `OfflineBanner` from `ui/core/widgets` when offline. Never hide failed syncs.

## Local tables (Drift)

- `cached_patients`
- `cached_appointments`
- `outbox_entries` (id, method, path, body_json, created_at, retry_count, last_error)
- `sync_meta` (collection, last_pulled_at)

## Outbox flush

Replay in insert order using existing REST `POST`/`PATCH`/`PUT`. On 409/422, mark the row failed and keep the local record; do not delete user data.

## Conflicts (MVP)

Last-write-wins using `updated_at`. If local and remote both changed odontogram/notes, keep local and flag `hasConflict` for staff review.

## Online-only (do not fake offline)

Copilot, Veri\*Factu, email send, SaaS admin, live PDF generation.

## Connectivity

`connectivity_plus` in `ConnectivityService`. Repositories ask this service; widgets ask a ViewModel/`SessionController`.
