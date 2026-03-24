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
│   │   ├── client_details_screen.dart
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

Final accepted result:
- PDF works
- branding works
- logo works
- Arabic PDF usable but not perfect

---

## Step 11 – Document Numbering System

Completed as one full step.

Implemented:
- invoice prefix
- quote prefix
- next invoice number
- next quote number
- automatic numbering generation
- local persistence
- numbering UI
- integrated into create flow

Final result:
- numbering stable and working

---

## Step 12 – Backup and Restore

Completed as one full step.

Implemented:
- JSON export & restore
- full data replacement
- provider refresh
- macOS entitlement fix

Final result:
- backup/restore fully working

---

## Step 13 – Edit Existing Clients and Documents

Completed as one full step.

Implemented:
- edit clients
- edit invoices/quotes
- duplicate prevention
- numbering fix
- improved ordering

Final result:
- edit flows stable

---

## Step 14 – Item Editing

Completed as one full step.

Implemented:
- edit items inline
- reuse dialog
- totals auto update

Final result:
- item editing stable

---

## Step 15 – Payment Tracking

Completed as one full step.

Implemented:
- paid amount
- remaining amount
- partial payments
- improved status system

Final result:
- real business payment tracking working

---

## Step 16 – Client Details + History

Completed as one full step.

Implemented:
- client details screen
- client invoice/quote history
- summary metrics:
  - total documents
  - invoices
  - quotes
  - total billed
  - total paid
  - total remaining
- direct access to document preview from client screen

Important fixes:
- handled status mismatch (`partial` vs `partially_paid`)
- fixed PDF status localization for partial payments

Final result:
- client becomes a full business entity view
- history and financial summary available per client
- navigation flow clean and intuitive
- Step 16 confirmed working

---

## Current Features

### Dashboard
- summary cards
- revenue overview

### Clients
- CRUD
- search
- details screen
- full history
- financial summary

### Invoices & Quotes
- create/edit
- item editing
- numbering
- payment tracking
- partial payments

### PDF
- full document generation
- localized
- branding

### Settings
- business profile
- currency
- numbering
- backup/restore

---

## Current State

- App stable
- Business-ready core features
- Clean user flows
- Ready for advanced UX improvements

---

## Known Issues

- Arabic PDF shaping not perfect
- PDF logic still duplicates some localization logic (to improve later)

---

## Deferred

- Arabic PDF improvements
- backend sync
- authentication
- UI polish improvements

---

## Next Step

## Step 17 – Dashboard Upgrade (Real Business Metrics)

Goal:
- upgrade dashboard to reflect real business data
- show:
  - total revenue
  - collected amount
  - outstanding balance
  - invoice counts by status
- improve decision-making visibility

---

## How to Continue

Repo: https://github.com/Mayyad78/invoiceflow  
Branch: main  
Last completed: Step 16  
Next task: Step 17

---

## Notes

- Do not restart project
- Keep incremental approach
- Stability over perfection