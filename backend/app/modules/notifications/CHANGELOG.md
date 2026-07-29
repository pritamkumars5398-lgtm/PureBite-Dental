# Changelog — notifications module

## Unreleased

- fix(smtp): the SMTP connection-test email was hardcoded Spanish copy
  signed "DentalPin", ignoring the clinic's communication language. It
  now resolves the locale via ``resolve_clinic_communication_locale``
  (es/en, falling back to the default) and signs with the clinic's own
  ``from_name`` or name. The API success message is localised the same
  way. Copy lives in ``_SMTP_TEST_COPY`` rather than a Jinja template
  because the test runs before template resolution is known to work.

- refactor(scheduler): declare the ``appointment_reminders`` interval job
  via ``get_scheduled_jobs()`` instead of being imported by name in
  ``app/core/scheduler.py``.
- refactor(types): drop the ``as unknown as Record<string, unknown>`` cast pattern (4 sites) in ``useNotificationSettings`` now that ``useApi`` accepts ``object`` payloads.
- fix(isolation): declare ``catalog`` in ``manifest.depends`` — the
  email-template handlers and the preview endpoint already imported
  catalog models to render line items. The dependency was real,
  just undeclared. ``KNOWN_VIOLATIONS`` allowlist trimmed
  accordingly.
- chore(events): subscribe via ``EventType.X`` constants instead of
  string literals — the events were already registered in the enum,
  the handler dict was the last drift site.
- Added per-module `CLAUDE.md` for AI-agent context (2026-04-27).

## 0.1.0 — initial

- Email templates, per-patient preferences, SMTP/console providers.
- APScheduler-backed sending queue (`tasks.py`).
- Subscribes to 6 events across patients, agenda, budget, billing.
