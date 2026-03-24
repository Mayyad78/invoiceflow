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
│   ├── app_fr.arb
│   └── app_localizations.dart
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
├── utils/
│   └── invoice_status_localizer.dart
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

Final result:
- PDF works
- branding works
- logo works
- Arabic PDF usable but not perfect

---

## Step 11 – Document Numbering System

Completed as one full step.

Final result:
- numbering stable and working

---

## Step 12 – Backup and Restore

Completed as one full step.

Final result:
- backup/restore fully working

---

## Step 13 – Edit Existing Clients and Documents

Completed as one full step.

Final result:
- edit flows work correctly
- no duplicates
- numbering preserved

---

## Step 14 – Item Editing Inside Invoice and Quote Forms

Completed as one full step.

Final result:
- items editable
- totals recalc correctly

---

## Step 15 – Payment Tracking

Completed as one full step.

Final result:
- paid / partial / remaining working

---

## Step 16 – Client Details

Completed as one full step.

Final result:
- client financial view working

---

## Step 17 – Dashboard Upgrade

Completed as one full step.

Final result:
- real business metrics working

---

## Step 18 – Status Localization Cleanup

Completed as one full step.

Final result:
- status logic centralized
- no duplication
- PDF and UI consistent

---

## Step 19 – Quote-to-Invoice Conversion (with Fix)

Completed as one full step.

Implemented:
- convert quote → invoice
- new invoice number generated
- quote preserved
- copied:
  - client
  - items
  - tax
  - discount
  - notes
- reset payment:
  - draft
  - paid = 0
- confirmation dialog

### Fix (critical improvement):
- added `convertedInvoiceId` to quote
- quote can only be converted once
- conversion button hidden after conversion
- visual indicator shown for converted quotes
- duplicate invoice creation prevented

Final result:
- safe real-world workflow
- no duplicate invoices from same quote
- conversion fully controlled and stable

---

## Current Features

### Dashboard
- full business metrics

### Clients
- CRUD + history + summary

### Invoices
- create/edit
- numbering
- payment tracking
- search
- ordering
- duplication prevention

### Quotes
- create/edit
- convert to invoice (safe)

### PDF
- branding + localization

### Settings
- profile
- currency
- numbering
- backup/restore

---

## Current State

- Stable
- Business-ready
- No critical issues
- Workflow aligned with real usage

---

## Known Issues

- Arabic PDF shaping not perfect

---

## Next Step

## Step 20 – Duplicate Invoice/Quote

Goal:
- duplicate existing invoice or quote
- generate new correct number
- speed up repeated business cases

---

## How to Continue

Repo: https://github.com/Mayyad78/invoiceflow  
Branch: main  
Last completed: Step 19  
Next task: Step 20

---

## Notes

- Do not restart project
- Continue incrementally
- Stability > perfection