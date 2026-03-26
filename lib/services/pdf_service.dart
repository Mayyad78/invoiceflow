import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/business_profile_model.dart';
import '../models/client_model.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';

class PdfService {
  Future<Uint8List> generateInvoicePdf({
    required InvoiceModel invoice,
    required ClientModel client,
    required BusinessProfileModel business,
    required String localeCode,
    required String currency,
  }) async {
    final pdf = pw.Document();

    final regularFont = await _loadRegularFont();
    final boldFont = await _loadBoldFont();
    final emojiFont = await _loadEmojiFont();

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      icons: emojiFont,
    );

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection:
            localeCode == 'ar' ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => [
          _buildHeader(
            invoice: invoice,
            business: business,
            localeCode: localeCode,
          ),
          pw.SizedBox(height: 20),
          _buildClientSection(
            client: client,
            localeCode: localeCode,
          ),
          pw.SizedBox(height: 20),
          _buildItemsTable(
            invoice: invoice,
            localeCode: localeCode,
            currency: currency,
          ),
          pw.SizedBox(height: 20),
          _buildTotalsSection(
            invoice: invoice,
            localeCode: localeCode,
            currency: currency,
          ),
          if (invoice.notes.trim().isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildNotesSection(
              notes: invoice.notes,
              localeCode: localeCode,
            ),
          ],
          pw.SizedBox(height: 24),
          _buildFooter(localeCode),
        ],
      ),
    );

    return pdf.save();
  }

  Future<pw.Font> _loadRegularFont() async {
    try {
      final data = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  Future<pw.Font> _loadBoldFont() async {
    try {
      final data = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return pw.Font.helveticaBold();
    }
  }

  Future<pw.Font> _loadEmojiFont() async {
    try {
      final data = await rootBundle.load('assets/fonts/NotoColorEmoji.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  String _tr(String localeCode, String key) {
    const map = {
      'en': {
        'invoice': 'Invoice',
        'quote': 'Quote',
        'invoiceNumber': 'Invoice Number',
        'quoteNumber': 'Quote Number',
        'issueDate': 'Issue Date',
        'dueDate': 'Due Date',
        'status': 'Status',
        'billTo': 'Bill To',
        'description': 'Description',
        'qty': 'Qty',
        'unitPrice': 'Unit Price',
        'total': 'Total',
        'subtotal': 'Subtotal',
        'tax': 'Tax',
        'discount': 'Discount',
        'paidAmount': 'Paid Amount',
        'remainingAmount': 'Remaining Amount',
        'notes': 'Notes',
        'thankYou': 'Thank you for your business',
        'statusDraft': 'Draft',
        'statusPaid': 'Paid',
        'statusUnpaid': 'Unpaid',
        'statusPartial': 'Partially Paid',
      },
      'ar': {
        'invoice': 'فاتورة',
        'quote': 'عرض سعر',
        'invoiceNumber': 'رقم الفاتورة',
        'quoteNumber': 'رقم عرض السعر',
        'issueDate': 'تاريخ الإصدار',
        'dueDate': 'تاريخ الاستحقاق',
        'status': 'الحالة',
        'billTo': 'العميل',
        'description': 'الوصف',
        'qty': 'الكمية',
        'unitPrice': 'سعر الوحدة',
        'total': 'الإجمالي',
        'subtotal': 'الإجمالي الفرعي',
        'tax': 'الضريبة',
        'discount': 'الخصم',
        'paidAmount': 'المبلغ المدفوع',
        'remainingAmount': 'المبلغ المتبقي',
        'notes': 'ملاحظات',
        'thankYou': 'شكراً لتعاملكم معنا',
        'statusDraft': 'مسودة',
        'statusPaid': 'مدفوع',
        'statusUnpaid': 'غير مدفوع',
        'statusPartial': 'مدفوع جزئياً',
      },
      'fr': {
        'invoice': 'Facture',
        'quote': 'Devis',
        'invoiceNumber': 'Numéro de facture',
        'quoteNumber': 'Numéro de devis',
        'issueDate': "Date d'émission",
        'dueDate': "Date d'échéance",
        'status': 'Statut',
        'billTo': 'Client',
        'description': 'Description',
        'qty': 'Qté',
        'unitPrice': 'Prix unitaire',
        'total': 'Total',
        'subtotal': 'Sous-total',
        'tax': 'Taxe',
        'discount': 'Remise',
        'paidAmount': 'Montant payé',
        'remainingAmount': 'Montant restant',
        'notes': 'Notes',
        'thankYou': 'Merci pour votre confiance',
        'statusDraft': 'Brouillon',
        'statusPaid': 'Payée',
        'statusUnpaid': 'Impayée',
        'statusPartial': 'Partiellement payée',
      },
    };

    return map[localeCode]?[key] ?? map['en']![key]!;
  }

  String _localizedStatus(String localeCode, String status) {
    switch (status) {
      case 'paid':
        return _tr(localeCode, 'statusPaid');
      case 'unpaid':
        return _tr(localeCode, 'statusUnpaid');
      case 'partial':
        return _tr(localeCode, 'statusPartial');
      default:
        return _tr(localeCode, 'statusDraft');
    }
  }

  String _formatCurrency(double value, String currency) {
    return '${value.toStringAsFixed(2)} $currency';
  }

  pw.Widget _buildHeader({
    required InvoiceModel invoice,
    required BusinessProfileModel business,
    required String localeCode,
  }) {
    final title =
        invoice.type == 'quote' ? _tr(localeCode, 'quote') : _tr(localeCode, 'invoice');
    final numberLabel = invoice.type == 'quote'
        ? _tr(localeCode, 'quoteNumber')
        : _tr(localeCode, 'invoiceNumber');

    final logoBytes = business.logoBytes;
    final isArabic = localeCode == 'ar';

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: isArabic
            ? [
                pw.Expanded(
                  child: _buildDocumentHeaderColumn(
                    invoice: invoice,
                    localeCode: localeCode,
                    title: title,
                    numberLabel: numberLabel,
                    alignEnd: false,
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: _buildBusinessHeaderColumn(
                    business: business,
                    logoBytes: logoBytes,
                    alignEnd: true,
                  ),
                ),
              ]
            : [
                pw.Expanded(
                  child: _buildBusinessHeaderColumn(
                    business: business,
                    logoBytes: logoBytes,
                    alignEnd: false,
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: _buildDocumentHeaderColumn(
                    invoice: invoice,
                    localeCode: localeCode,
                    title: title,
                    numberLabel: numberLabel,
                    alignEnd: true,
                  ),
                ),
              ],
      ),
    );
  }

  pw.Widget _buildBusinessHeaderColumn({
    required BusinessProfileModel business,
    required Uint8List? logoBytes,
    required bool alignEnd,
  }) {
    return pw.Column(
      crossAxisAlignment:
          alignEnd ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        if (logoBytes != null) ...[
          pw.Container(
            width: 72,
            height: 72,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Image(
              pw.MemoryImage(logoBytes),
              fit: pw.BoxFit.contain,
            ),
          ),
          pw.SizedBox(height: 10),
        ],
        pw.Text(
          business.name.trim().isEmpty ? 'InvoiceFlow' : business.name,
          textAlign: alignEnd ? pw.TextAlign.right : pw.TextAlign.left,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (business.phone.trim().isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            business.phone,
            textAlign: alignEnd ? pw.TextAlign.right : pw.TextAlign.left,
          ),
        ],
        if (business.email.trim().isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            business.email,
            textAlign: alignEnd ? pw.TextAlign.right : pw.TextAlign.left,
          ),
        ],
        if (business.address.trim().isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            business.address,
            textAlign: alignEnd ? pw.TextAlign.right : pw.TextAlign.left,
          ),
        ],
      ],
    );
  }

  pw.Widget _buildDocumentHeaderColumn({
    required InvoiceModel invoice,
    required String localeCode,
    required String title,
    required String numberLabel,
    required bool alignEnd,
  }) {
    return pw.Column(
      crossAxisAlignment:
          alignEnd ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          textAlign: alignEnd ? pw.TextAlign.right : pw.TextAlign.left,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        _headerInfoLine(
          label: numberLabel,
          value: invoice.invoiceNumber,
          alignEnd: alignEnd,
        ),
        pw.SizedBox(height: 6),
        _headerInfoLine(
          label: _tr(localeCode, 'issueDate'),
          value: DateFormat('yyyy-MM-dd').format(invoice.issueDate),
          alignEnd: alignEnd,
        ),
        pw.SizedBox(height: 6),
        _headerInfoLine(
          label: _tr(localeCode, 'dueDate'),
          value: DateFormat('yyyy-MM-dd').format(invoice.dueDate),
          alignEnd: alignEnd,
        ),
        pw.SizedBox(height: 6),
        _headerInfoLine(
          label: _tr(localeCode, 'status'),
          value: _localizedStatus(localeCode, invoice.status),
          alignEnd: alignEnd,
        ),
      ],
    );
  }

  pw.Widget _headerInfoLine({
    required String label,
    required String value,
    required bool alignEnd,
  }) {
    return pw.Row(
      mainAxisAlignment:
          alignEnd ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
      children: alignEnd
          ? [
              pw.Flexible(
                child: pw.Text(
                  value,
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                '$label:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ]
          : [
              pw.Text(
                '$label:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(width: 6),
              pw.Flexible(
                child: pw.Text(
                  value,
                  textAlign: pw.TextAlign.left,
                ),
              ),
            ],
    );
  }

  pw.Widget _buildClientSection({
    required ClientModel client,
    required String localeCode,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: localeCode == 'ar'
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _tr(localeCode, 'billTo'),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(client.name),
          if (client.phone.trim().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(client.phone),
          ],
          if (client.email.trim().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(client.email),
          ],
          if (client.address.trim().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(client.address),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable({
    required InvoiceModel invoice,
    required String localeCode,
    required String currency,
  }) {
    final headers = [
      _tr(localeCode, 'description'),
      _tr(localeCode, 'qty'),
      _tr(localeCode, 'unitPrice'),
      _tr(localeCode, 'total'),
    ];

    final data = invoice.items.map((InvoiceItemModel item) {
      return [
        item.description,
        item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 2),
        _formatCurrency(item.unitPrice, currency),
        _formatCurrency(item.total, currency),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
      headerPadding: const pw.EdgeInsets.all(8),
    );
  }

  pw.Widget _buildTotalsSection({
    required InvoiceModel invoice,
    required String localeCode,
    required String currency,
  }) {
    final rows = <List<String>>[
      [_tr(localeCode, 'subtotal'), _formatCurrency(invoice.subtotal, currency)],
      [_tr(localeCode, 'tax'), _formatCurrency(invoice.taxAmount, currency)],
      [_tr(localeCode, 'discount'), _formatCurrency(invoice.discount, currency)],
      [_tr(localeCode, 'total'), _formatCurrency(invoice.total, currency)],
    ];

    if (invoice.type == 'invoice') {
      rows.add([
        _tr(localeCode, 'paidAmount'),
        _formatCurrency(invoice.paidAmount, currency),
      ]);
      rows.add([
        _tr(localeCode, 'remainingAmount'),
        _formatCurrency(invoice.remainingAmount, currency),
      ]);
    }

    return pw.Align(
      alignment:
          localeCode == 'ar' ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
      child: pw.Container(
        width: 260,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: rows.map((row) {
            final isTotal = row[0] == _tr(localeCode, 'total');
            final isRemaining = row[0] == _tr(localeCode, 'remainingAmount');

            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    row[0],
                    style: pw.TextStyle(
                      fontWeight: (isTotal || isRemaining)
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                    ),
                  ),
                  pw.Text(
                    row[1],
                    style: pw.TextStyle(
                      fontWeight: (isTotal || isRemaining)
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  pw.Widget _buildNotesSection({
    required String notes,
    required String localeCode,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: localeCode == 'ar'
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _tr(localeCode, 'notes'),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(notes),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(String localeCode) {
    return pw.Center(
      child: pw.Text(
        _tr(localeCode, 'thankYou'),
        style: const pw.TextStyle(
          color: PdfColors.grey700,
        ),
      ),
    );
  }
}