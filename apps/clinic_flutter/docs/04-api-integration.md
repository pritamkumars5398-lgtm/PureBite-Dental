# API integration

Mirror the web client in `frontend/app/composables/useApi.ts`.

## Single client

`ApiClient` wraps Dio. Created once in `config/di.dart`.

Interceptors (order):

1. Attach `Authorization: Bearer <access>` unless `skipAuth`.
2. On **401**: refresh via `ApiConstants.refresh`, retry **once**, else logout.
3. On **403** with `subscription_expired`: surface locked state (same as web `/locked`).
4. Map network failures to `AppException`.

## Result type

Repositories return `Result<T>` (`core/utils/result.dart`): `Ok` or `Err`. Views never `try/catch` HTTP.

## Mapping

```
JSON DTO (data/models) → Domain (domain/models) inside the repository
```

ViewModels only see domain models.

## Auth sequence

1. `POST login` with form fields `username` (email) and `password`.
2. Store tokens in `flutter_secure_storage` (`StorageKeys.accessToken`, `refreshToken`).
3. `GET me` to load user, clinics, permissions.
4. Select clinic (first membership until clinic-switch UI exists). Send `clinic_id` query when the backend supports it.

## DRY

- Feature services expose methods like `listPatients(...)` that call `api.get(ApiConstants.patients, query: ...)`.
- Do not copy interceptors, envelope parsing, or refresh logic.
