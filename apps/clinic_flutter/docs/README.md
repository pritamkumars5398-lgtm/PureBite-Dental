# Clinic Flutter — Rules and Docs

This folder is the **single source of truth** before code. Every screen, API call, spacing value, and icon size must follow these documents.

| Doc | What it covers |
|-----|----------------|
| [01-architecture.md](01-architecture.md) | Layers, folders, who may import whom |
| [02-design-tokens.md](02-design-tokens.md) | Spacing, icons, text, color, radius |
| [03-api-constants.md](03-api-constants.md) | All API URLs and header keys |
| [04-api-integration.md](04-api-integration.md) | Dio client, JWT refresh, envelopes |
| [05-offline-sync.md](05-offline-sync.md) | Local-first reads, outbox, conflicts |
| [06-adaptive-layout.md](06-adaptive-layout.md) | Phone / tablet / desktop layouts |
| [07-coding-conventions.md](07-coding-conventions.md) | DRY, naming, no magic numbers |
| [08-utils.md](08-utils.md) | Shared helpers — when and where |
| [09-feature-workflow.md](09-feature-workflow.md) | How to add a new feature |
| [10-i18n.md](10-i18n.md) | English / Spanish strings |
| [11-remaining-screens.md](11-remaining-screens.md) | Web vs Flutter screen inventory — what is still left |

Cursor rules that enforce the same contracts live in [`.cursor/rules/`](../.cursor/rules/).

**Do not invent new tokens, paths, or layers.** Extend the listed files instead.
