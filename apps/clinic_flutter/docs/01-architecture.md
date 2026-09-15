# Architecture

Staff clinic app for DentalPin. Same FastAPI backend as the Nuxt web app. Flutter is the offline clinical client.

## Layers

```
View (UI) → ViewModel → Repository → Services (API / Drift / secure storage)
```

| Layer | May know about | Must not know about |
|-------|----------------|---------------------|
| **View** | ViewModel, theme, widgets, l10n | Dio, Drift, tokens, JSON |
| **ViewModel** | Repositories, domain models | Widgets, BuildContext, HTTP paths |
| **Repository** | Services, DTO → domain mapping, cache, outbox | Widgets, Theme |
| **Service** | One external system (HTTP **or** DB **or** OS) | Other services' internals, UI |

Domain use cases exist only when two ViewModels would copy the same business rule (sync flush, conflict merge).

## Folder map

```
lib/
  main.dart
  app.dart
  config/di.dart
  l10n/
  core/
    constants/          # AppSpacing, AppIcons, ApiConstants, …
    theme/              # colors + TextTheme + ThemeData
    utils/              # Result, validators, dates, strings
    errors/             # AppException
  data/
    models/             # API DTOs
    services/api/
    services/local/
    services/connectivity/
    repositories/
  domain/models/
  ui/
    core/widgets/       # shared only
    core/layout/
    features/<name>/view_models/
    features/<name>/views/
```

## DRY import rules

- Views import `package:clinic_flutter/core/constants/...` and `ui/core/widgets`. Never duplicate padding numbers.
- Feature folders do not import other feature folders. Cross-feature data goes through a repository.
- One `ApiClient`. Feature code never constructs `Dio()`.

## State

- ViewModels extend `ChangeNotifier`.
- Views use `ListenableBuilder`.
- Inject dependencies in the constructor. Register in `config/di.dart` (`get_it`).
