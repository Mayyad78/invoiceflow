# InvoiceFlow – Project Context

## 🧱 Tech Stack

* Flutter
* Riverpod
* intl (l10n)
* Hive (local storage)
* pdf
* printing
* share_plus

---

## 📁 Project Structure

lib/
├── features/
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── clients/
│   │   └── clients_screen.dart
│   ├── invoices/
│   │   ├── invoices_screen.dart
│   │   ├── create_invoice_screen.dart
│   │   ├── invoice_preview_screen.dart
│   │   └── widgets/
│   │       └── add_item_dialog.dart
│   └── settings/
│       ├── settings_screen.dart
│       └── business_profile_screen.dart
│
├── models/
│   ├── client_model.dart
│   ├── invoice_model.dart
│   ├── invoice_item_model.dart
│   ├── business_profile_model.dart
│   └── app_settings_model.dart
│
├── providers/
│   ├── clients_provider.dart
│   ├── invoices_provider.dart
│   ├── business_profile_provider.dart
│   ├── app_settings_provider.dart
│   ├── settings_service_provider.dart
│   ├── invoice_service_provider.dart
│   └── pdf_service_provider.dart
│
├── services/
│   ├── invoice_service.dart
│   ├── pdf_service.dart
│   ├── settings_service.dart
│   └── local_storage_service.dart
│
└── l10n/
├── app_en.arb
├── app_ar.arb
└── app_fr.arb

---

## ✅ Current Features

### Clients

* Add / delete clients
* Stored locally using Hive

### Invoices & Quotes

* Create invoice/quote
* Add multiple items
* Tax & discount calculation
* Save locally

### Invoice List

* View invoices
* Filter by type (invoice / quote)
* Delete invoice
* Preview button

### PDF

* Generate PDF using `pdf`
* Includes:

  * business profile
  * client data
  * items
  * totals
* Works:

  * Print ✅
  * Share ✅
* Preview:

  * macOS ✅
  * Web ❌ (fallback UI)

### Settings

* Business profile (editable & saved)
* Currency selector (USD, EUR, GBP, JOD, AED)
* Language switch (EN / AR / FR)

---

## ⚠️ Known Limitations

* Web PDF preview not working → fallback used
* No backend (local only)
* Arabic PDF glyphs render, but proper Arabic joining/  shaping is still unresolved in current PDF stack
* Attempted arabic_reshaper package, but it was unstable for this workflow
---

## 🎯 Next Step

Step 7:

* Invoice status (paid/unpaid)
* Search & filter
* Dashboard improvements

---

## 📌 Rules

* Always follow existing structure
* Provide full file paths
* Provide full code (no partial)