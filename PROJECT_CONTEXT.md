# InvoiceFlow – Project Context

This file contains the full working context of the project so development can continue across chats without losing progress.

---

## Project Overview

InvoiceFlow is a local-first Flutter invoicing app.

Core principles:
- No backend for now
- Local-first using Hive
- Clean UI
- Multi-language support (EN / AR / FR)

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
- Preserve current UI
- Use full file replacements
- Do not provide git commit commands until the full step is running correctly and the user confirms
- Do not update PROJECT_CONTEXT.md until the full step is running correctly and the user confirms
- Do not create new variable names when the project already has existing names for the same purpose; stick to current project naming and structure

IMPORTANT WORKFLOW RULE:
- After each completed step:
  - ALWAYS generate FULL updated PROJECT_CONTEXT.md
  - Do NOT provide partial updates
  - Do NOT require manual merging
  - Must include:
    - all completed steps
    - latest completed step
    - final outcome of the step
    - important fixes/decisions inside that step
    - current state
    - next step
- After the step is confirmed working:
  - update PROJECT_CONTEXT.md first
  - then provide git commit commands
  - both should happen together only after confirmation
- Always include the full project structure with all files so it is clear what files were added or changed
- If adding a new file, clearly say where it connects
- Prefer safe full-file replacements over partial edits

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
│   ├── backup_restore_service_provider.dart
│   ├── business_profile_provider.dart
│   ├── client_service_provider.dart
│   ├── clients_provider.dart
│   ├── invoice_service_provider.dart
│   ├── invoices_provider.dart
│   ├── locale_provider.dart
│   ├── pdf_service_provider.dart
│   └── settings_service_provider.dart
├── services/
│   ├── backup_restore_service.dart
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

## Steps 1 to 9

Completed and working:
- Flutter project setup
- localization (EN / AR / FR)
- dashboard base
- models
- Hive local storage
- clients CRUD
- invoice and quote creation
- PDF generation
- print and share
- macOS preview
- web fallback for PDF
- business profile
- currency selector
- invoice status
- search for clients and invoices
- dashboard summary cards
- delete confirmations
- empty state polish
- localized PDF labels
- branding improvements

System stable through Step 9.

---

## Step 10 – PDF, Branding, and Arabic Handling

Completed and accepted as one phase.

Implemented:
- Arabic font added to PDF workflow
- logo upload added to business profile
- logo stored locally as base64
- logo preview added
- logo included in PDF header
- header layout reviewed and improved

Important notes:
- English and French PDF output are stable
- Arabic glyph rendering works better than before
- Arabic shaping/joining is still not solved correctly
- multiple Arabic/header layout refinements were tested
- final decision was to stop further tuning for now and keep a stable usable version

Final accepted result:
- PDF works
- branding works
- logo works
- Arabic PDF is usable but not perfect
- deeper Arabic shaping/layout improvements are deferred

---

## Step 11 – Document Numbering System

Completed as one full step.

Implemented:
- invoice prefix
- quote prefix
- next invoice number
- next quote number
- automatic numbering generation
- local persistence for numbering settings
- numbering settings UI inside Settings
- numbering integrated into invoice/quote creation flow

Important fixes included inside this same step:
- fixed crash caused by older saved settings that did not contain the new numbering values
- fixed numbering settings sheet layout so fields display correctly and do not overlap

Final accepted result:
- numbering works correctly
- prefixes save correctly
- invoice and quote numbering are separated
- values increment correctly
- settings persist locally
- UI is stable
- backward compatibility for older saved settings is handled

Note:
- Step 11 should be treated as one completed feature step, not multiple sub-steps or separate commit stages

---

## Step 12 – Backup and Restore

Completed as one full step.

Implemented:
- JSON backup export
- JSON backup restore
- backup includes:
  - clients
  - invoices
  - business profile
  - app settings
- restore performs a full local replace of current stored data
- backup/restore UI added inside Settings
- restore confirmation dialog added
- provider refresh after restore so restored data appears immediately in UI

Important fixes and decisions:
- kept the architecture local-first with Hive
- kept Riverpod architecture
- used file_selector for choosing export and restore files
- used a simple versioned JSON payload
- restore validates file shape before replacing existing data
- restore skips invalid entries without IDs instead of crashing
- settings restore writes business profile and app settings back to the settings box using the existing keys
- macOS export issue was fixed by adding the required user-selected file entitlements in:
  - macos/Runner/DebugProfile.entitlements
  - macos/Runner/Release.entitlements
- export flow was aligned with the current file_selector save dialog handling so backup export works correctly on macOS

Final accepted result:
- user can export a full local backup file
- user can restore a previous backup file
- clients, invoices, business profile, and settings are restored together
- restore immediately refreshes the app state
- UI stays simple and matches the current app style
- export works correctly on macOS after the entitlement fix

---

## Current Features

### Dashboard
- total invoices
- paid invoices
- unpaid invoices
- total revenue
- pending amount

### Clients
- add client
- list clients
- delete client
- search clients
- local storage

### Invoices and Quotes
- create invoices
- create quotes
- select client
- add multiple items
- tax and discount calculation
- save locally
- status support
- search invoices
- numbering support

### PDF
- generate invoice and quote PDFs
- print
- share
- macOS preview
- web fallback UI
- localized labels
- business profile included
- currency included
- logo included

### Settings
- business profile
- currency selector
- document numbering settings
- backup export
- backup restore
- local persistence

---

## Current State

- App stable
- Core features working
- PDF working
- Logo working
- Numbering working
- Backup and restore working
- Ready for next major feature step

---

## Known Issues

- Arabic text shaping in PDF is not solved
- Arabic PDF layout is acceptable but not perfect
- web embedded PDF preview is limited

---

## Deferred / Return Later

1. proper Arabic shaping/joining in generated PDFs
2. deeper Arabic PDF layout/header polish
3. richer web PDF preview
4. cloud sync / backend
5. authentication
6. advanced branding polish

---

## Next Step

## Step 13 – Edit Existing Clients and Documents

Goal:
- edit existing clients
- edit existing invoices
- edit existing quotes
- preserve numbering correctly during edits
- keep local-first architecture
- keep UI simple and safe

Preferred approach:
- add edit actions from list screens
- reuse current form screens where possible
- preserve original document number when editing an existing invoice/quote
- avoid creating duplicate records during edit

---

## How to Continue in New Chat

Repo: https://github.com/Mayyad78/invoiceflow
Branch: main
Last completed: Step 12
Next task: Step 13

Rules:
- keep Riverpod
- keep local-first
- no backend yet
- preserve current UI style
- always provide FULL file path
- always provide FULL code for any changed file
- do not provide partial snippets unless explicitly asked
- do not provide git commit commands until the full step is running correctly and confirmed
- do not update PROJECT_CONTEXT.md until the full step is running correctly and confirmed
- do not create new variable names if the project already has existing names for the same purpose
- after each confirmed step, update PROJECT_CONTEXT.md first, then provide git commit commands
- continue from the current architecture, do not restart the project
- if adding a new file, clearly say where it connects
- prefer safe full-file replacements over partial edits
- after each successful step, always generate the FULL updated PROJECT_CONTEXT.md file in one block
- always include the full project structure with all files after each confirmed step

---

## Notes

- Do not restart the project
- Continue incrementally
- Stability is more important than perfection
- Avoid breaking working features
- Step 13 should be built as one full step