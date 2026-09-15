# Design tokens

Aligned with DentalPin web design system. **Never hardcode** `EdgeInsets`, `fontSize`, or icon `size` in widgets. Use these classes only:

| File | Class |
|------|--------|
| `lib/core/constants/app_spacing.dart` | `AppSpacing` |
| `lib/core/constants/app_icons.dart` | `AppIcons` |
| `lib/core/constants/app_radii.dart` | `AppRadii` |
| `lib/core/constants/app_durations.dart` | `AppDurations` |
| `lib/core/constants/app_breakpoints.dart` | `AppBreakpoints` |
| `lib/core/theme/app_colors.dart` | `AppColors` |
| `lib/core/theme/app_text.dart` | `AppText` |

## Spacing (4 px base)

| Token | px | Use |
|-------|----|-----|
| `xxs` | 4 | Icon-to-label gap, error text gap |
| `xs` | 8 | Chip padding, tight stacks |
| `sm` | 12 | Compact card padding, form field gap (compact) |
| `md` | 16 | Default card padding, form field gap |
| `lg` | 20 | Comfortable card header |
| `xl` | 24 | Between cards |
| `xxl` | 32 | Between page sections |
| `xxxl` | 48 | Page top/bottom on desktop |

Tap targets: **minimum 44 px** (`AppSpacing.tapTarget`).

```dart
// BAD
padding: const EdgeInsets.all(16)

// GOOD
padding: const EdgeInsets.all(AppSpacing.md)
```

## Icon sizes

| Token | px | Use |
|-------|----|-----|
| `sm` | 16 | Inline in captions, badges |
| `md` | 20 | List leading, form prefix |
| `lg` | 24 | App bar, nav rail, buttons |
| `xl` | 32 | Empty states |
| `nav` | 20 | Sidebar Lucide icons (same as `md`) |

Use `AppIcon` widget (`ui/core/widgets/app_icon.dart`) so size + color stay consistent.

Lucide icons are the only icon set. Default size is **20 px** (`AppIcons.md` / `AppIcons.lucide` / `AppIcons.nav`). Empty states use `xl` (32).

Saturated color is **only** for icons, 2–3 px rails, 1 px borders, and destructive buttons — never large fills.

## Text (Inter)

| Token | Size | Weight | Use |
|-------|------|--------|-----|
| `display` | 28 | 700 | Page titles, KPIs |
| `h1` | 22 | 700 | Screen titles |
| `h2` | 18 | 600 | Card headers |
| `h3` | 15 | 600 | Panel headers |
| `body` | 14 | 400 | Default |
| `prose` | 15 | 400 | Clinical notes |
| `ui` | 14 | 500 | Labels, nav |
| `button` | 14 | 600 | Buttons |
| `caption` | 12 | 500 | Timestamps, badges |
| `micro` | 11 | 600 | Odontogram tags |

Widgets use `Theme.of(context).textTheme` / `AppText.theme`. Never `TextStyle(fontSize: 14)`.

User-visible copy comes from **l10n**, not string literals.

## Radius

`xs` 4 · `sm` 6 · `md` 8 · `lg` 12 · `xl` 16 · `pill` 999

## Motion

Transitions ≤ 150 ms (`AppDurations.fast`). No decorative animation. Respect reduced motion.
