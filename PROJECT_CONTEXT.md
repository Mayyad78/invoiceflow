# InvoiceFlow – Project Context

This file contains the full working context of the project so development can continue across chats without losing progress.

---

## Project Overview

InvoiceFlow is a local-first Flutter invoicing app.

Core principles:
- No backend (for now)
- Local-first (Hive)
- Clean UI
- Multi-language (EN / AR / FR)

---

## Tech Stack

- Flutter
- Riverpod
- Hive
- intl / l10n
- pdf
- printing
- share_plus
- image_picker
- file_selector

---

## Development Rules (CRITICAL)

- Keep Riverpod
- Keep local-first
- No backend
- Preserve UI
- Use full file replacements

IMPORTANT WORKFLOW RULE:
- After each completed step:
  - ALWAYS generate FULL updated PROJECT_CONTEXT.md
  - Do NOT provide partial updates
  - Do NOT require manual merging
  - Must include:
    - all steps
    - latest step
    - bugs
    - fixes
    - decisions
    - current state
    - next step

---

## Full Project Structure

lib/
├── app/
│   └── app.dart
├── features/
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── clients/
│   │   ├── add_client_screen.dart
│   │   └── clients_screen.dart
│   ├── invoices/
│   │   ├── create_invoice_screen.dart
│   │   ├── invoice_preview_screen.dart
│   │   ├── invoices_screen.dart
│   │   └── widgets/
│   │       └── add_item_dialog.dart
│   └── settings/
│       ├── business_profile_screen.dart
│       └── settings_screen.dart
├── l10n/
│   ├── app_ar.arb
│   ├── app_en.arb
│   └── app_fr.arb
├── models/
│   ├── app_settings_model.dart
│   ├── business_profile_model.dart
│   ├── client_model.dart
│   ├── invoice_item_model.dart
│   └── invoice_model.dart
├── providers/
│   ├── app_settings_provider.dart
│   ├── business_profile_provider.dart
│   ├── client_service_provider.dart
│   ├── clients_provider.dart
│   ├── invoice_service_provider.dart
│   ├── invoices_provider.dart
│   ├── locale_provider.dart
│   ├── pdf_service_provider.dart
│   └── settings_service_provider.dart
├── services/
│   ├── client_service.dart
│   ├── invoice_service.dart
│   ├── local_storage_service.dart
│   ├── pdf_service.dart
│   └── settings_service.dart
└── main.dart

Other important files:
- pubspec.yaml
- l10n.yaml
- PROJECT_CONTEXT.md
- README.md
- macos/Runner/DebugProfile.entitlements
- macos/Runner/Release.entitlements

---

## Steps 1 → 9

All core features implemented:
- clients CRUD
- invoices & quotes
- PDF generation
- dashboard
- localization
- settings
- search
- UI polish

System stable.

---

## Step 10 – PDF + Branding

### Step 10a – Arabic PDF
- Arabic font added
- glyphs render correctly
- shaping NOT solved

Decision:
- defer shaping to later
- keep stable version

Final:
- EN / FR correct
- AR readable but not perfect

---

### Step 10b – Logo
- logo picker added
- stored locally (base64)
- preview works
- appears in PDF

Fix:
- macOS entitlement issue solved

Final:
- logo fully working

---

### Step 10c – Header
- layout improvements done

Issues:
- Arabic layout inconsistency

Decision:
- keep unified layout
- stop further tuning

Final:
- header stable and usable

---

## Step 11 – Document Numbering

### Implemented
- invoice prefix
- quote prefix
- next invoice number
- next quote number
- auto increment
- settings UI
- local persistence

---

### Bugs

1. Crash:
type 'Null' is not a subtype of type 'int'

Cause:
- old saved data missing new fields

Fix:
- safe parsing (_readInt / _readString)

---

2. Layout issue:
- overlapping fields in sheet

Fix:
- replaced Wrap → Column + SingleChildScrollView

---

### Final State

- numbering works correctly
- prefixes saved
- increment works
- invoice & quote separated
- UI fixed
- no crashes
- backward compatible

---

## Current State

- App stable
- Core features working
- PDF working
- Logo working
- Numbering working

---

## Known Issues

- Arabic text shaping not solved
- Web PDF preview limited

---

## Deferred

1. Arabic shaping
2. PDF polish
3. backup/restore
4. cloud sync
5. authentication

---

## Next Step

Step 12 – Backup & Restore

- export data (JSON)
- import data
- restore:
  - clients
  - invoices
  - settings
  - business profile