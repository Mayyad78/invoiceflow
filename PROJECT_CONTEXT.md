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
│   │   ├── templates_screen.dart
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

## Step 20 – Duplicate Invoice/Quote

Completed as one full step.

Implemented:
- duplicate existing invoice
- duplicate existing quote
- duplicate action added in invoices/quotes list
- duplicated document opens in form before saving
- new document number generated through existing numbering system
- new unique ID generated for duplicated document
- copied:
  - client
  - items
  - tax
  - discount
  - notes
- duplicated invoice resets payment state:
  - status = draft
  - paidAmount = 0
- duplicated quote remains a quote
- duplicated quote is NOT marked as converted
- issue date reset to current date
- due date recalculated from the original document timing
- edit flow preserved separately from duplicate flow

### Important fixes/decisions inside Step 20:
- kept existing project structure and naming
- preserved `InvoicesScreen(type: ...)` contract
- preserved real `InvoiceModel` fields:
  - `invoiceNumber`
  - `clientId`
  - `items`
  - `taxPercent`
  - `discount`
  - `notes`
  - `paidAmount`
  - `convertedInvoiceId`
- preserved Step 19 protection for already converted quotes
- restored provider methods expected by current screens:
  - `addInvoice`
  - `updateInvoice`
  - `deleteInvoice`
- added duplicate localization label to l10n files

Final result:
- repeated business cases are faster
- user can reuse invoices and quotes safely
- no overwrite of original document
- quote conversion safety remains intact
- duplicate workflow is stable and working

---

## Step 21 – Templates

Completed as one full step.

Implemented:
- save invoice as template
- save quote as template
- new templates screen added:
  - `lib/features/invoices/templates_screen.dart`
- templates accessible from invoices/quotes app bar
- templates filtered by document type:
  - invoice templates
  - quote templates
- use template opens the create form before saving
- creating from template generates a normal new document
- templates are hidden from normal invoice/quote list screens
- template keeps:
  - client
  - items
  - tax
  - discount
  - notes
- template usage resets:
  - new unique ID
  - new document number
  - status = draft
  - paidAmount = 0
- template usage clears quote conversion link when needed

### Important fixes/decisions inside Step 21:
- reused existing `InvoiceModel` instead of creating a separate template model
- added `isTemplate` flag to `InvoiceModel`
- kept storage local and simple by using the existing invoice storage flow
- preserved duplicate flow from Step 20
- preserved quote conversion safety from Step 19
- preserved numbering system from Step 11
- added new localization labels for templates in EN / AR / FR
- templates remain editable through the normal “use template → open form → save” flow
- template items are cloned safely before reuse

Final result:
- repeated business workflows are much faster
- invoice and quote templates are now supported
- no impact on normal invoice/quote lists
- template workflow is stable and working

---

## Step 22 – Template Management Improvements

Completed as one full step.

Implemented:
- save as template from create screen
- save as template from edit screen
- save as template from invoice/quote list screen
- template naming support
- template rename support
- template direct edit support
- improved templates empty state
- improved template labels and management flow
- use template still opens form before saving
- using template still creates a normal document
- templates remain hidden from normal invoice/quote list screens

### Important fixes/decisions inside Step 22:
- extended `InvoiceModel` with:
  - `templateName`
- preserved existing:
  - `isTemplate`
  - `convertedInvoiceId`
  - numbering flow
  - duplicate flow
- added dedicated template management actions:
  - use template
  - edit template
  - rename template
  - delete template
- template edit remains inside existing `CreateInvoiceScreen`
- when editing a template:
  - no real invoice number is used
  - payment section is hidden
  - save updates the template itself instead of creating a normal invoice
- saving as template from form prompts for template name before storing
- template usage clears:
  - `templateName`
  - `convertedInvoiceId`
  - paid state
- added new localization labels for EN / AR / FR:
  - template name
  - rename template
  - edit template
  - template updated
  - delete template confirmation
  - improved empty-state guidance
- fixed Flutter dialog crash during template save/rename flow
  - removed fragile `Form + GlobalKey` dialog implementation
  - replaced with safer `StatefulBuilder` dialog handling
  - resolved assertion:
    - `'package:flutter/src/widgets/framework.dart': Failed assertion: line 6268 pos 12: '_dependents.isEmpty': is not true.`

Final result:
- template management is complete and stable
- template naming works
- template rename works
- template edit works
- template save from form works
- no crash in template name dialog flow
- Step 19, Step 20, and Step 21 behaviors remain intact

---

## Step 22 UX Improvements – Template Search and Favorites

Completed as one full step.

Implemented:
- template search bar
- search by:
  - template name
  - client name
  - notes
- favorite / pin template support
- favorites-only filter chip
- favorites displayed first in template list
- better no-results state when search/filter returns nothing
- favorite badge shown on favorited templates

### Important fixes/decisions inside this UX step:
- extended `InvoiceModel` with:
  - `isFavoriteTemplate`
- kept template data inside existing storage model
- preserved:
  - template naming
  - template edit
  - template rename
  - template use flow
- favorite status persists in storage
- using a template resets favorite state on the created real document
- search and filter logic only affects templates screen
- normal invoices and quotes remain unchanged
- added new localization labels in EN / AR / FR:
  - search templates
  - favorites only
  - no templates found
  - try different search or filter
  - favorite
  - add to favorites
  - remove from favorites

Final result:
- template UX is much better
- users can find templates faster
- important templates can be pinned and reused quickly
- all previous template functionality remains stable

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
- duplicate support
- template support
- save as template from form/list

### Quotes
- create/edit
- convert to invoice (safe)
- duplicate support
- template support
- conversion lock after use
- save as template from form/list

### Templates
- save invoice as template
- save quote as template
- filtered templates by type
- create new document from template
- rename template
- edit template directly
- delete template
- search templates
- favorite / pin templates
- favorites-only filter
- improved empty state and labels

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
- Template system is now mature and highly usable
- Ready to continue with export/share improvements

---

## Known Issues
- Arabic PDF shaping not perfect

---

## Next Step

## Step 23 – Export / Share Improvements

Goal:
- improve export and sharing workflow

Suggested scope:
- improve PDF naming with invoice/quote number
- cleaner share flow
- quick share options
- optional image export if feasible within current architecture

---

## How to Continue

Repo:
https://github.com/Mayyad78/invoiceflow

Branch:
main

Last completed:
Step 22 UX Improvements

Next task:
Step 23

---

## Notes
- Do not restart project
- Continue incrementally
- Stability > perfection