# Feature workflow

Add features in this order. Skip use cases for simple CRUD.

1. Domain model (`lib/domain/models`)
2. DTO + parse (`lib/data/models`)
3. API methods using **only** `ApiConstants`
4. Drift table if the feature must work offline
5. Repository (local read, outbox write, map DTO → domain)
6. ViewModel (`ChangeNotifier`)
7. View (adaptive, tokens, l10n)
8. Register in `config/di.dart` and `go_router`
9. Tests

## MVP order

See [11-remaining-screens.md](11-remaining-screens.md) for the live leftover list (~43 screens).

1. Auth + shell
2. Patients (list + detail tabs)
3. Appointments (week calendar)
4. Quotes / invoices / payments
5. Odontogram + clinical notes on the patient
6. Settings editors
