# InvoiceFlow – Project Context

This file contains the full working context of the project so development can continue across chats without losing progress.

---

## Project Overview

InvoiceFlow is a **local-first Flutter invoicing app** designed for small businesses and freelancers.

Core idea:

* No backend (for now)
* Everything stored locally
* Fast and simple workflow
* Clean UI
* Multi-language support (EN / AR / FR)

---

## Tech Stack

* Flutter
* Riverpod
* Hive (local storage)
* intl / l10n
* pdf
* printing
* share_plus
* image_picker
* file_selector (desktop support)

---

## Architecture Rules (IMPORTANT)

* Keep Riverpod (DO NOT replace)
* Keep current folder structure
* Keep local-first approach
* No backend for now
* Preserve current UI style
* Prefer full file replacements when editing
* Avoid breaking working features
* Build step-by-step, not big rewrites

---

## Project Structure

```text
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
```

---

## Completed Steps

### Step 1

* Flutter project initialized
* l10n added (EN / AR / FR)
* dashboard + settings base

### Step 2

* models created
* Hive local storage added
* local storage service implemented

### Step 3

* clients feature completed
* add / list / delete clients
* stored locally

### Step 4

* invoice & quote creation
* items
* tax & discount
* save locally

### Step 5

* PDF generation
* print support
* share support
* macOS preview works
* web fallback implemented

### Step 6

* business profile
* currency selector
* settings stored locally
* PDF uses settings

### Step 7a

* invoice status:

  * draft
  * paid
  * unpaid

### Step 7b

* search clients
* search invoices

### Step 7c

* dashboard stats:

  * total invoices
  * paid
  * unpaid
  * revenue
  * pending

### Step 8

* delete confirmations
* empty states
* UI polish

### Step 9

* localized PDF labels
* EN / AR / FR support in PDF
* improved branding layout

---

## Step 10 Summary

### Step 10a – Arabic PDF rendering

* Added Arabic font: NotoSansArabic
* English & French stable
* Arabic readable but:
  ❌ proper shaping/joining NOT solved
* Tried arabic_reshaper → caused instability → rolled back

### Step 10b – Business logo

* logo picker added
* works on web and macOS (after entitlements fix)
* logo stored locally (base64)
* preview works
* logo appears in PDF

### Step 10c – PDF header polishing

* header layout reviewed and improved
* alignment fixes for logo and business info
* decision taken:
  ✅ keep **unified header layout across all languages**
* Arabic layout improvements partially attempted
* final decision:
  ❌ stop further tuning now to avoid time waste
  🔁 revisit later if needed

---

## Current Features

### Clients

* CRUD
* search
* local storage

### Invoices / Quotes

* create
* edit
* items
* tax / discount
* status
* search

### PDF

* generate invoice & quote
* print
* share
* macOS preview
* web fallback
* localized labels
* business profile included
* currency applied
* logo included

### Settings

* business profile
* currency selector
* local persistence

---

## Known Limitations

### PDF / Arabic

* Arabic letters are NOT properly joined
* layout is acceptable but not perfect
* needs future dedicated fix

### Web

* no full PDF preview
* fallback UI used

### General

* no backend
* no auth
* no sync
* no backup/restore
* no invoice numbering system

---

## Deferred / Return Later

These are intentionally postponed:

1. Arabic text shaping (CRITICAL but complex)
2. deeper Arabic PDF layout polish
3. web PDF preview improvement
4. backup & restore
5. invoice numbering system
6. cloud sync / backend
7. authentication
8. advanced branding

---

## Current State

* App is stable
* Core features working
* PDF functional
* Logo feature completed
* Ready for next feature step

---

## Next Step

### Step 11 – Document Numbering System

Goal:

* invoice prefix (e.g., INV-)
* quote prefix
* next invoice number
* next quote number
* auto increment
* stored locally
* used during invoice creation

---

## After Step 11

### Step 12 – Backup & Restore

* export data
* import data
* restore clients
* restore invoices
* restore settings

---

## How to Continue in New Chat

Provide:

Repo: https://github.com/Mayyad78/invoiceflow
Branch: main
Last completed: Step 10c
Next task: Step 11

Rules:

* keep Riverpod
* keep local-first
* no backend
* preserve UI
* full file replacements
* provide test steps
* provide git commands

---

## Notes

* Do NOT restart project
* Continue incrementally
* Stability > perfection
* Avoid breaking working features
