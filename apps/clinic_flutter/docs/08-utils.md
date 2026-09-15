# Utils

Helpers live in `lib/core/utils/`. **Do not** put utils inside feature folders. If two features need it, it belongs here.

| File | Responsibility |
|------|----------------|
| `result.dart` | `Result<T>`, `Ok`, `Err` |
| `validators.dart` | email, required, password min length |
| `date_utils.dart` | ISO parse/format, clinic-local day bounds, display dates |
| `string_utils.dart` | `fullName`, search normalize, initials |
| `json_utils.dart` | safe `asString`, `asBool`, nested map reads |
| `page_utils.dart` | page/pageSize clamp to API caps |

## Rules

- Utils are **pure** (no `BuildContext`, no Dio, no Drift).
- Formatting that needs locale uses `intl` with the locale passed in — or a View helper that calls l10n.
- Keep functions small. If a helper knows about patients **and** appointments, split it.
