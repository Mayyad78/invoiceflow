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
- Always provide downloadable links for every changed file
- Always provide downloadable link for updated PROJECT_CONTEXT.md
- Keep chat small; prefer download links over pasting large files in chat

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
  - Must also include upcoming development steps so a new chat can continue immediately
  - If a new step is introduced later, reorder the upcoming steps accordingly
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
│   ├── catalog_item_model.dart
│   ├── client_model.dart
│   ├── invoice_item_model.dart
│   └── invoice_model.dart
├── providers/
│   ├── app_settings_provider.dart
│   ├── backup_restore_service_provider.dart
│   ├── business_profile_provider.dart
│   ├── catalog_items_provider.dart
│   ├── catalog_item_service_provider.dart
│   ├── client_service_provider.dart
│   ├── clients_provider.dart
│   ├── invoice_service_provider.dart
│   ├── invoices_provider.dart
│   ├── locale_provider.dart
│   ├── pdf_service_provider.dart
│   └── settings_service_provider.dart
├── services/
│   ├── backup_restore_service.dart
│   ├── catalog_item_service.dart
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

## Step 23 – Export / Share Improvements and Partial Payment Display Fix

Completed as one full step.

Implemented:
- improved invoice/quote preview screen UX
- better PDF file naming using document type + invoice/quote number
- preview header card now shows:
  - document number
  - client
  - total
  - PDF file name
- export PDF action kept as dedicated safe action
- refresh preview action added
- restored built-in `PdfPreview` print/share controls on supported platforms
- improved web fallback export section
- invoice/quote list action overflow fixed by changing action layout:
  - visible actions:
    - preview
    - edit
    - duplicate
  - popup menu actions:
    - save as template
    - delete
    - convert to invoice (quotes only)
- removed yellow/black overflow warning caused by too many action buttons in a single row

### Partial payment display fix:
- invoice preview now shows:
  - total
  - paid amount
  - remaining amount
  for invoices
- web fallback preview also shows:
  - total
  - paid amount
  - remaining amount
  for invoices
- PDF totals section now includes:
  - subtotal
  - tax
  - discount
  - total
  - paid amount
  - remaining amount
  for invoices
- partial paid invoices now produce accurate preview + PDF output
- quotes still do not show paid/remaining values

### Important fixes/decisions inside Step 23:
- kept current PDF generation architecture
- avoided risky custom print flow after macOS print support issue
- removed custom share button from preview in favor of built-in supported share inside `PdfPreview`
- kept explicit export action using `Printing.sharePdf`
- preserved all earlier flows:
  - Step 19 quote conversion
  - Step 20 duplication
  - Step 21 templates
  - Step 22 template management
  - Step 22 UX improvements
- maintained current model structure and naming

Final result:
- preview/export flow is cleaner and more stable
- overflow issue on invoice/quote cards is fixed
- file naming is improved
- partially paid invoices now display correct payment details in both preview and PDF
- business document accuracy is improved

---

## Step 24 – UX & Business Flow Polish

Completed as one full step.

Implemented:
- improved invoice and quote card readability
- better spacing inside document cards
- clearer grouping for:
  - total
  - paid
  - remaining
- highlighted important values to improve quick reading
- improved card action layout while preserving existing flows
- improved dashboard clarity for financial summary
- clearer distinction between:
  - collected amount
  - pending amount
- improved preview screen hierarchy and summary layout
- cleaner preview header and amount grouping
- fixed missing company logo in PDF
- improved PDF header separation between business information and document information

### Important fixes/decisions inside Step 24:
- preserved existing project naming and structure
- corrected provider usage to keep existing `appSettingsProvider`
- did not introduce risky changes to working Step 19–23 flows
- kept current PDF logic stable
- restored company logo rendering in PDF without changing the rest of the PDF workflow
- kept Arabic PDF full shaping/layout work postponed to a later isolated step to avoid breaking stable output
- kept preview/export flow stable on macOS
- preserved template system, duplicate flow, conversion flow, and partial payment flow

Final result:
- invoice and quote lists are easier to read
- dashboard financial summary is clearer
- preview screen is cleaner and easier to understand
- PDF branding is restored with company logo
- application remains stable and working after the UX polish step

---

## Step 25 – Mobile Preview UX Polish

Completed as one full step.

Implemented:
- reduced invoice preview header height on mobile
- increased PDF preview area on mobile screens
- improved spacing in the preview screen for smaller screens
- kept preview actions clean and usable
- replaced unstable preview action behavior with controlled export/print actions
- export now uses the correct PDF file name instead of a random temp file name
- print flow from the preview screen was fixed
- kept PDF generation logic unchanged for this step
- kept Arabic PDF untouched in this step

### Important fixes/decisions inside Step 25:
- preserved stable Step 24 behavior as the base
- did not reuse discarded Arabic PDF attempts
- did not change English/French PDF business logic
- fixed preview export naming to use document-based file names
- fixed print action behavior from the preview screen
- corrected invoice details header block in English/French so the label appears first and the value appears to the right
- preserved:
  - partial payment preview
  - partial payment PDF output
  - company logo in PDF
  - templates flow
  - duplicate flow
  - quote conversion protection
- kept changes focused on preview UX and safe PDF header alignment correction only

Final result:
- invoice preview is better on mobile
- preview area is larger and cleaner
- export file naming is correct
- print works correctly from preview
- English/French invoice details block now reads correctly
- Step 19–24 flows remain stable

---

## Step 26 – Application Cards Polish

Completed as one full step.

Implemented:
- reduced dashboard card sizes for mobile usability
- optimized spacing and padding
- adjusted font sizes for compact layout
- improved grid proportions
- improved status cards layout
- improved quick action cards sizing
- improved cash flow card spacing
- consistent compact styling across dashboard

### Important fixes/decisions inside Step 26:
- no logic changes
- no calculation changes
- preserved navigation
- preserved providers and architecture
- focused only on dashboard for safe UX improvement

Final result:
- smaller, cleaner dashboard cards
- better mobile/tablet usability
- more content visible on screen
- no regressions

---

## Step 27 – Application Functionality Enhancements

Completed as one full step.

Implemented:
- creating invoice from client details now preselects the client
- improved invoice and quote screen logic
- status filter chips now appear only on invoices
- quote screen simplified since quotes are always drafts
- improved search behavior across invoice and quote screens
- kept quote conversion, duplication, preview, edit, and template actions working

### Important fixes/decisions inside Step 27:
- quotes remain draft-only documents
- status filtering applies only to invoices
- removed references to non-existing localization keys
- preserved all existing architecture and providers
- no changes to PDF generation, numbering, templates, backup/restore, or payment logic
- kept the client details → new invoice workflow aligned with real use by opening invoice creation with the current client preselected

Final result:
- cleaner quote interface
- improved client → invoice workflow
- application functionality improved without regressions

---

## Step 28 – Invoice Creation Speed Improvements

Completed as one full step.

Implemented:
- improved invoice and quote list entry flow for faster daily usage
- added direct templates access from the list summary area
- added quick reuse action for the latest document from the main list screen
- improved client details quick actions for faster document creation
- added duplicate latest invoice action inside client details when available
- kept new invoice from client details preselected to the current client
- preserved existing create screen logic while making entry points faster

### Important fixes/decisions inside Step 28:
- kept `CreateInvoiceScreen` architecture unchanged for safety
- did not change invoice save logic, numbering logic, template logic, or payment logic
- focused on faster entry points instead of risky deep form refactoring
- preserved existing duplication behavior by reusing the stable duplicate flow
- preserved existing template screen flow by exposing it faster from the list summary area
- kept all changes aligned with real daily usage patterns

Final result:
- faster access to create, duplicate, and templates flows
- reduced friction for repeated invoice creation
- application workflow is faster without regressions

---

## Step 29 – Client Workflow Improvements

Completed as one full step.

Implemented:
- added New Invoice action directly on each client card
- added New Quote action directly on each client card
- each client card now supports faster document creation with that client already preselected
- added New Quote action inside client details
- preserved New Invoice action inside client details
- preserved Duplicate Latest Invoice action inside client details
- improved speed of client-based invoice and quote creation
- kept preview and edit flows working from clients screens

### Important fixes/decisions inside Step 29:
- reused existing `CreateInvoiceScreen`
- reused the stable prefilled draft approach for client preselection
- did not refactor invoice form internals
- preserved numbering logic
- preserved template logic
- preserved payment logic
- focused only on faster client workflow without changing core architecture

Final result:
- much faster client-based document creation
- invoices and quotes can now be started directly from client screens
- no regressions in existing flows

---

## Step 30 – Invoice Form Workflow Polish

Completed as one full step.

Implemented:
- improved Add Item visibility inside the invoice form
- improved empty items state so users can add the first item faster
- made item entry more obvious and faster for daily use
- fixed Save as Template cancel crash
- simplified template dialog lifecycle while preserving existing save behavior

### Important fixes/decisions inside Step 30:
- kept existing `CreateInvoiceScreen` architecture
- did not change numbering logic
- did not change template save logic outside the dialog lifecycle fix
- did not change payment logic
- did not change PDF generation logic
- fixed the Flutter assertion crash triggered when pressing Cancel in the template name dialog:
  - `'package:flutter/src/widgets/framework.dart': Failed assertion: line 6268 pos 12: '_dependents.isEmpty': is not true.`
- kept the step focused on invoice form workflow and stability only

Final result:
- invoice form is faster to use
- Save as Template cancel no longer crashes the app
- invoice form workflow is smoother and stable

---

## Step 31 – Product Catalog (Quick Invoice Items)

Completed as one full step.

Implemented:
- added product catalog support for reusable invoice items
- added new catalog files:
  - `lib/models/catalog_item_model.dart`
  - `lib/services/catalog_item_service.dart`
  - `lib/providers/catalog_item_service_provider.dart`
  - `lib/providers/catalog_items_provider.dart`
- added catalog storage box support in local storage service
- added catalog bottom sheet inside invoice form
- added Add Product flow inside catalog
- added Edit Product flow inside catalog
- added Delete Product flow inside catalog
- added Add to invoice flow from catalog
- made catalog bottom sheet mobile-safe with close button and draggable layout
- prevented duplicate catalog products by product name
- added invoice item merge behavior when same item is added again
- adding the same catalog item to the invoice now increases quantity instead of creating duplicate rows
- restored bookmark icon purpose:
  - Add Item → invoice only
  - Bookmark → save invoice item to catalog intentionally
- disabled bookmark button when invoice item already exists in catalog
- editing a linked catalog item updates active invoice item price and description
- linked active invoice item quantity remains unchanged when catalog item is edited
- deleting a catalog item safely unlinks active invoice items without crashing
- updated add item dialog button labels:
  - Add when creating a new item
  - Save Changes when editing an existing item

### Important fixes/decisions inside Step 31:
- catalog duplicates are prevented by item name only
- Add Item no longer auto-saves to catalog
- bookmark icon remains meaningful and intentionally saves item to catalog
- linked catalog item sync is limited to active invoice form state only
- kept existing invoice save logic unchanged
- kept numbering logic unchanged
- kept template logic unchanged
- kept payment logic unchanged
- kept PDF logic unchanged
- all catalog files must remain listed in project structure and future context files

Final result:
- product catalog is now integrated into invoice workflow
- reusable items are supported safely
- invoice entry is faster and cleaner
- catalog workflow is stable and mobile-friendly
- no regressions in previous steps

---

## Step 32 – Catalog Autocomplete

Completed as one full step.

Implemented:
- item description field now searches catalog while typing
- suggestions appear inside Add Item dialog
- user can tap a suggestion to auto-fill:
  - description
  - quantity
  - unit price
- manual item entry still works without selecting a suggestion
- dialog layout kept mobile-safe and stable
- existing add item flow preserved
- bookmark-to-catalog flow preserved
- catalog bottom sheet behavior preserved

### Important fixes/decisions inside Step 32:
- kept current `CreateInvoiceScreen` call contract intact
- kept autocomplete inside existing item dialog instead of adding a new screen
- avoided risky changes to PDF, templates, numbering, payments, and Arabic PDF
- kept catalog integration limited to invoice item entry speed improvement
- maintained Step 31 catalog behavior as the base

Final result:
- invoice item entry is faster
- catalog suggestions work during typing
- user can select existing catalog items quickly
- no regressions in Step 19–31 flows

---

## Step 33 – Catalog Logic Stabilization

Completed as one full step.

Implemented:
- stabilized repeated catalog item behavior inside the active invoice draft
- same catalog item now merges into one invoice row using `catalogItemId` first
- selecting the same catalog item again from catalog/autocomplete no longer creates a second row just because the price was changed in the draft
- removed the risky smart-default direction before it affected stable invoice behavior
- kept autocomplete behavior working
- kept manual Add Item behavior working
- kept bookmark-to-catalog flow working
- kept catalog bottom sheet workflow working

### Important fixes/decisions inside Step 33:
- catalog should remain a speed tool, not a complex inventory system
- predictable behavior is better than hidden smart memory for this app
- one catalog item in one invoice should stay one row
- bookmark logic remains aligned with the current catalog matching rule
- active invoice draft keeps its edited unit price when the catalog product itself is edited
- no automatic price/quantity memory was introduced
- no changes to PDF, templates, numbering, payments, or Arabic PDF

Final result:
- catalog logic is simpler and more predictable
- duplicate rows from the same catalog item are prevented
- invoice item entry stays fast without confusing behavior
- Step 31 and Step 32 remain stable on top of the new catalog rule

---

## Step 34 – Invoice Item Editing UX

Completed as one full step.

Implemented:
- tapping an existing invoice item row now opens the edit dialog directly
- edit icon remains available
- delete icon remains available
- Save as Template action remains available
- Save Invoice action remains available
- payment section remains visible and unchanged
- totals section remains visible and unchanged
- catalog flow remains available
- autocomplete flow remains available

### Important fixes/decisions inside Step 34:
- kept the full Step 33 screen intact
- avoided replacing the working invoice form UI
- added only the row-tap editing improvement
- preserved Step 31 catalog integration
- preserved Step 32 autocomplete behavior
- preserved Step 33 stabilized merge logic
- no changes to PDF, templates, numbering, payments, or Arabic PDF

Final result:
- invoice item editing is faster on mobile and desktop
- user can tap the row itself instead of aiming only for the small edit icon
- existing working flows remain intact
- no regressions in Step 19–33 flows

---

## Current Features

### Dashboard
- full business metrics
- clearer collected vs pending display
- compact mobile-friendly cards

### Clients
- CRUD + history + summary
- client details screen
- create new invoice from client details with that client already preselected
- create new quote from client details with that client already preselected
- create new invoice directly from clients screen with that client already preselected
- create new quote directly from clients screen with that client already preselected
- duplicate latest invoice from client details

### Invoices
- create/edit
- numbering
- payment tracking
- search
- ordering
- status filter chips
- duplicate support
- template support
- save as template from form/list
- quick reuse of latest document
- faster access to templates from list summary area
- improved invoice form item entry
- item merge behavior for repeated items
- partial payment display in preview and PDF
- improved card readability for total / paid / remaining
- tap row to edit item

### Quotes
- create/edit
- convert to invoice (safe)
- duplicate support
- template support
- conversion lock after use
- save as template from form/list
- simplified list/readability layout
- no invoice-only status chips shown
- faster access to templates from list summary area

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
- stable template dialog cancel flow

### Product Catalog
- add product
- edit product
- delete product
- reuse product in invoice
- duplicate prevention by name
- mobile-safe catalog sheet
- linked item sync in active invoice form
- autocomplete in Add Item dialog
- same catalog item merges into one invoice row

### PDF
- branding + localization
- improved file naming
- accurate paid/remaining display for invoices
- company logo restored
- English/French header details block corrected

### Preview / Export
- improved preview header
- dedicated export PDF action
- refresh preview action
- cleaner summary layout
- improved mobile preview spacing
- larger mobile PDF preview area
- corrected export filename behavior
- corrected preview print flow

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
- Template system is mature and highly usable
- Partial payment display is accurate in preview and PDF
- Document readability improved
- Dashboard clarity improved
- PDF logo restored
- Mobile preview UX improved
- Application functionality improved
- Invoice creation flow is faster
- Client workflow is faster
- Invoice form workflow is improved
- Product catalog is working
- Catalog autocomplete is working
- Catalog duplicate row logic is stabilized
- Invoice item editing UX is improved
- Ready for the next focused improvement

---

## Known Issues
- Arabic PDF shaping not perfect
- Arabic PDF layout still needs dedicated RTL polish
- Arabic PDF formatting remains postponed to a later isolated step

---

## Upcoming Development Steps
- Step 35 – Invoice Search & Filters
- Step 36 – Data Export Tools
- Step 37 – Arabic PDF RTL Fix

Note:
- upcoming steps may be reordered if a new functionality step is introduced before them

---

## Step 35 – Invoice Search & Filters

Goal:
- improve invoice and quote list navigation once data grows
- allow faster search by client, document number, and item description
- improve filters for payment status and document finding speed
- keep current invoice creation and catalog logic stable

Suggested scope:
- search by invoice/quote number
- search by client
- search by item description
- quick status filters
- preserve current invoice logic and catalog rules

---

## How to Continue

Repo:
https://github.com/Mayyad78/invoiceflow

Branch:
main

Last completed:
Step 34

Next task:
Step 35

---

## Notes
- Do not restart project
- Continue incrementally
- Stability > perfection
- Keep current naming and structure
- Focus on application functionality before Arabic PDF polish
- Do not break Steps 19–34
