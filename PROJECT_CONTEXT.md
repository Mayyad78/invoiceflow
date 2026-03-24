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
- local persistence

---

## Current State

- App stable
- Core features working
- PDF working
- Logo working
- Numbering working
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

## Step 12 – Backup and Restore

Goal:
- export local app data
- import local app data
- restore:
  - clients
  - invoices
  - settings
  - business profile

Preferred approach:
- JSON export/import
- simple and safe full local replace on restore
- keep Hive/local-first architecture
- keep UI simple

---

## How to Continue in New Chat

Repo: https://github.com/Mayyad78/invoiceflow
Branch: main
Last completed: Step 11
Next task: Step 12

Rules:
- keep Riverpod
- keep local-first
- no backend yet
- preserve current UI style
- always provide FULL file path
- always provide FULL code for any changed file
- do not provide partial snippets unless explicitly asked
- after each step, provide:
  1. files changed
  2. what to test
  3. git commands to commit and push
- continue from the current architecture, do not restart the project
- if adding a new file, clearly say where it connects
- prefer safe full-file replacements over partial edits
- after each successful step, always generate the FULL updated PROJECT_CONTEXT.md file in one block

---

## Notes

- Do not restart the project
- Continue incrementally
- Stability is more important than perfection
- Avoid breaking working features
- Step 12 should be built as one full step