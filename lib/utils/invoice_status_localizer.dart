import '../l10n/app_localizations.dart';

String normalizeInvoiceStatus(String status) {
  switch (status) {
    case 'partially_paid':
      return 'partial';
    case 'paid':
    case 'unpaid':
    case 'partial':
    case 'draft':
      return status;
    default:
      return 'draft';
  }
}

String localizeInvoiceStatus(AppLocalizations t, String status) {
  switch (normalizeInvoiceStatus(status)) {
    case 'paid':
      return t.statusPaid;
    case 'unpaid':
      return t.statusUnpaid;
    case 'partial':
      return t.statusPartial;
    default:
      return t.statusDraft;
  }
}

String localizeInvoiceStatusByLocaleCode(String localeCode, String status) {
  final normalizedStatus = normalizeInvoiceStatus(status);

  switch (localeCode) {
    case 'ar':
      switch (normalizedStatus) {
        case 'paid':
          return 'مدفوع';
        case 'unpaid':
          return 'غير مدفوع';
        case 'partial':
          return 'مدفوع جزئياً';
        default:
          return 'مسودة';
      }

    case 'fr':
      switch (normalizedStatus) {
        case 'paid':
          return 'Payée';
        case 'unpaid':
          return 'Impayée';
        case 'partial':
          return 'Partiellement payée';
        default:
          return 'Brouillon';
      }

    default:
      switch (normalizedStatus) {
        case 'paid':
          return 'Paid';
        case 'unpaid':
          return 'Unpaid';
        case 'partial':
          return 'Partially Paid';
        default:
          return 'Draft';
      }
  }
}