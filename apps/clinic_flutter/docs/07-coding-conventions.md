# Coding conventions

## DRY

- One widget for a repeated pattern (`AppButton`, `AppTextField`, `AppCard`, `AppIcon`, `EmptyState`, `LoadingView`).
- One gap widget: `AppGap.sm()` etc. — do not sprinkle `SizedBox(height: 12)`.
- Copy lives in ARB files. Concatenate with l10n placeholders, not `'Hello $name'` in UI.

## Forbidden

```dart
EdgeInsets.all(16)           // use AppSpacing
Icon(Icons.person, size: 24) // use AppIcon + AppIcons
TextStyle(fontSize: 14)      // use AppText / textTheme
'/api/v1/patients'           // use ApiConstants
'Offline'                    // use AppLocalizations
Dio()                        // use injected ApiClient
```

## Naming

- Files: `snake_case.dart`
- Types: `PascalCase`
- ViewModels: `SomethingViewModel`
- Repositories: `SomethingRepository`
- Private fields: `_underscore`

## Comments

No comments that repeat the code. Comments only for non-obvious backend quirks (login is unwrapped, etc.).

## Tests

Repository + ViewModel unit tests for each feature. Widget test the adaptive shell at 390, 800, and 1280 widths.
