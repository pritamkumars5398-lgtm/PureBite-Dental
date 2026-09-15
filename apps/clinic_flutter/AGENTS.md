# Clinic Flutter agent guide

You are working on `PureBite-Dental/apps/clinic_flutter`.

1. Read `docs/README.md` and the doc for the layer you touch.
2. Follow `.cursor/rules/*.mdc`.
3. Never hardcode spacing, icon size, font size, or API paths.
4. UI reads local data only. HTTP belongs in services behind repositories.
5. User-visible strings go in `lib/l10n/*.arb`.

Layers: View → ViewModel → Repository → Service.
