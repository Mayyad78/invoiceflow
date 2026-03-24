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
- final decision was to stop further tuning for now and keep a stable usable version

Final accepted result:
- PDF works
- branding works
- logo works
- Arabic PDF is usable but not perfect

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

Important fixes:
- handled old saved settings without numbering values
- fixed layout issues in numbering UI

Final result:
- numbering works correctly
- prefixes persist
- values increment correctly
- UI stable

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
- restore replaces all local data
- provider refresh after restore

Important fixes:
- macOS export fixed using entitlements
- file_selector save dialog corrected

Final result:
- export works
- restore works
- full data recovery working
- UI stable

---

## Step 13 – Edit Existing Clients and Documents

Completed as one full step.

Implemented:
- edit clients
- edit invoices
- edit quotes
- reuse existing screens
- preserve document numbers
- prevent duplicate clients
- fix invoice numbering during creation
- improved invoice ordering (newest first)

Final result:
- edit flows work correctly
- no duplicates
- numbering preserved
- UX improved

---

## Step 14 – Item Editing Inside Invoice and Quote Forms

Completed as one full step.

Implemented:
- edit existing items inside invoice and quote forms
- reuse add item dialog for editing
- add edit button for each item
- update item inline without recreating list
- totals automatically recalculate after edit

Important decisions:
- no new screens added, reused dialog
- minimal UI change to preserve current design
- kept create/edit invoice flow unchanged
- edit + delete actions shown together per item

Final result:
- items can be edited safely
- totals update correctly after edit
- no duplicate items created
- UX significantly improved
- Step 14 confirmed working

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
- edit client
- delete client
- search clients
- duplicate protection

### Invoices and Quotes
- create invoices
- create quotes
- edit invoices
- edit quotes
- add/edit/delete items
- tax and discount calculation
- numbering system
- search invoices
- newest-first ordering

### PDF
- generate PDFs
- print
- share
- preview
- branding + logo

### Settings
- business profile
- currency
- numbering
- backup & restore

---

## Current State

- App stable
- All core flows working
- Editing flows complete
- Item editing complete
- Ready for next feature

---

## Known Issues

- Arabic PDF shaping not perfect
- web PDF preview limited

---

## Deferred

- Arabic PDF improvements
- backend / sync
- authentication
- advanced branding

---

## Next Step

## Step 15 – Invoice/Quote Status Improvements + Paid Tracking

Goal:
- improve invoice status handling
- track paid amount / remaining amount
- prepare for real business usage

---

## How to Continue

Repo: https://github.com/Mayyad78/invoiceflow  
Branch: main  
Last completed: Step 14  
Next task: Step 15

---

## Notes

- Do not restart project
- Keep incremental approach
- Stability over perfection