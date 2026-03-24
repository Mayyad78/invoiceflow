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

## Step 15 – Invoice/Quote Status Improvements + Paid Tracking

Completed as one full step.

Implemented:
- added paid amount to invoice model
- added remaining amount calculation to invoice model
- improved invoice payment status handling
- added support for draft, unpaid, partial, and paid invoice states
- moved invoice status and paid amount handling into the invoice form
- added invoice summary display for paid amount and remaining amount
- invoice list now shows:
  - total
  - paid amount
  - remaining amount
  - payment status badge

Important decisions:
- quote flow stays simple and does not use payment tracking
- partial payment requires entering a paid amount
- paid status auto-fills the full total as paid amount
- unpaid and draft reset paid amount to zero
- status dropdown was removed from the list screen because partial payment needs amount input and is safer inside the invoice form
- existing create/edit flow was preserved while extending the business logic

Final result:
- invoices now support real payment tracking
- partial payment works correctly
- remaining balance is calculated correctly
- invoice list reflects payment progress clearly
- quote flow remains clean and unaffected
- Step 15 confirmed working

---

## Step 16 – Client Details + Client Invoice History

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

## Step 17 – Dashboard Upgrade (Real Business Metrics)

Completed as one full step.

Implemented:
- upgraded dashboard to use real invoice payment data
- added dashboard metrics:
  - total revenue
  - collected amount
  - outstanding balance
  - total clients
  - total invoices
  - total quotes
- added invoice status breakdown:
  - paid
  - unpaid
  - partially paid
  - draft
- kept quick actions working with current navigation flow
- ensured quotes affect quote count but do not distort invoice payment metrics

Important decisions:
- dashboard now separates invoices from quotes before calculating payment-related metrics
- outstanding balance is based on remaining amounts from invoices
- collected amount is based on paid amounts from invoices
- kept the dashboard structure simple while making the numbers more useful for real business follow-up
- used existing localization structure for new dashboard labels

Final result:
- dashboard now reflects real business performance
- user can quickly see collected money vs pending money
- invoice status overview is clearer
- dashboard is much more useful for day-to-day business tracking
- Step 17 confirmed working

---

## Step 18 – Centralized Status Localization + PDF Cleanup

Completed as one full step.

Implemented:
- added shared status helper file:
  - `lib/utils/invoice_status_localizer.dart`
- centralized invoice status normalization
- centralized invoice status localization for UI
- centralized invoice status localization by locale code for PDF usage
- updated invoice list to use shared helper
- updated client details screen to use shared helper
- updated dashboard calculations to use normalized status values
- updated PDF service to use shared helper instead of manual duplicated status strings

Important decisions:
- `partial` remains the official current status value
- backward compatibility kept for older `partially_paid` values
- status fallback remains `draft` only for unknown or missing values
- kept PDF localization compatible with current structure without requiring a larger localization refactor
- reduced duplication without changing working business flows

Final result:
- status text is now consistent across UI and PDF
- older stored data with `partially_paid` still works correctly
- partially paid status no longer falls back incorrectly in PDF or UI
- repeated status logic was removed from multiple files
- Step 18 confirmed working

---

## Current Features

### Dashboard
- total revenue
- collected amount
- outstanding balance
- total clients
- total invoices
- total quotes
- invoice status breakdown
- quick actions

### Clients
- add client
- list clients
- edit client
- delete client
- search clients
- duplicate protection
- client details screen
- client history
- client financial summary

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
- payment status tracking
- paid amount
- remaining amount
- partial payment support

### PDF
- generate PDFs
- print
- share
- preview
- branding + logo
- localized status display
- centralized status handling for PDF

### Settings
- business profile
- currency
- numbering
- backup & restore

---

## Current State

- App stable
- Business-ready core features
- Clean user flows
- Dashboard reflects real metrics
- Status localization logic is now centralized and more maintainable
- Ready for next feature

---

## Known Issues

- Arabic PDF shaping not perfect
- PDF still has some non-status text localized manually by locale code instead of fully sharing app localization

---

## Deferred

- Arabic PDF improvements
- backend sync
- authentication
- UI polish improvements
- broader PDF text localization cleanup

---

## Next Step

## Step 19 – Quote-to-Invoice Conversion

Goal:
- allow converting a saved quote into an invoice
- preserve client and item data
- generate a proper invoice number using the numbering system
- improve the real sales workflow from quotation to billing

---

## How to Continue

Repo: https://github.com/Mayyad78/invoiceflow
Branch: main
Last completed: Step 18
Next task: Step 19

---

## Notes

- Do not restart project
- Keep incremental approach
- Stability over perfection