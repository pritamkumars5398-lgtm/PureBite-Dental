# Adaptive layout

Layouts follow **window width**, not device type. No `Platform.isIOS` layout switches. No orientation lock.

## Breakpoints (`AppBreakpoints`)

| Name | maxWidth | Chrome |
|------|----------|--------|
| compact | < 600 | Bottom `NavigationBar` |
| medium | 600–1023 | `NavigationRail` + list/detail |
| expanded | ≥ 1024 | Rail + wider master/detail |

Use `LayoutBuilder` / `MediaQuery.sizeOf(context)`. Do **not** use `MediaQuery.orientationOf` at the app root.

## Shared widgets

- `AdaptiveScaffold` — nav + body
- `AdaptiveMasterDetail` — list | detail split when width ≥ medium
- Forms and long text: `ConstrainedBox(maxWidth: AppBreakpoints.contentMax)` (800) centered

## Density

Comfortable is default. Compact only on odontogram, calendar, treatment lists. On compact width, tap targets stay ≥ 44 px.

## Input

Support touch, mouse, and keyboard. Icon-only buttons need `tooltip` + `semanticsLabel`.
