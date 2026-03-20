import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/business_profile_model.dart';
import '../models/client_model.dart';
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

    final strings = _pdfStrings(localeCode, invoice.type);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        strings.title,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      _infoLine(strings.numberLabel, invoice.invoiceNumber),
                      _infoLine(
                        strings.dateLabel,
                        invoice.issueDate.toLocal().toString().split(' ').first,
                      ),
                      _infoLine(
                        strings.dueLabel,
                        invoice.dueDate.toLocal().toString().split(' ').first,
                      ),
                      _infoLine(
                        strings.statusLabel,
                        _localizedStatus(localeCode, invoice.status),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 24),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        business.name.isEmpty ? 'InvoiceFlow' : business.name,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                      if (business.email.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          business.email,
                          textAlign: pw.TextAlign.right,
                        ),
                      ],
                      if (business.phone.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          business.phone,
                          textAlign: pw.TextAlign.right,
                        ),
                      ],
                      if (business.address.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          business.address,
                          textAlign: pw.TextAlign.right,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 28),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(
                  pw.Radius.circular(8),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    strings.billToLabel,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(client.name),
                  if (client.email.isNotEmpty) pw.Text(client.email),
                  if (client.phone.isNotEmpty) pw.Text(client.phone),
                  if (client.address.isNotEmpty) pw.Text(client.address),
                ],
              ),
            ),
            pw.SizedBox(height: 28),
            pw.TableHelper.fromTextArray(
              headers: [
                strings.descriptionLabel,
                strings.quantityLabel,
                strings.unitPriceLabel,
                strings.totalLabel,
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey700,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(8),
              data: invoice.items
                  .map(
                    (item) => [
                      item.description,
                      item.quantity.toString(),
                      '${item.unitPrice.toStringAsFixed(2)} $currency',
                      '${item.total.toStringAsFixed(2)} $currency',
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 24),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 240,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  children: [
                    _summaryRow(
                      strings.subtotalLabel,
                      '${invoice.subtotal.toStringAsFixed(2)} $currency',
                    ),
                    _summaryRow(
                      strings.taxLabel,
                      '${invoice.taxAmount.toStringAsFixed(2)} $currency',
                    ),
                    _summaryRow(
                      strings.discountLabel,
                      '${invoice.discount.toStringAsFixed(2)} $currency',
                    ),
                    pw.Divider(),
                    _summaryRow(
                      strings.totalLabel,
                      '${invoice.total.toStringAsFixed(2)} $currency',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            if (invoice.notes.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Text(
                strings.notesLabel,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(invoice.notes),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _infoLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  pw.Widget _summaryRow(String label, String value, {bool isBold = false}) {
    final style = isBold
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)
        : null;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  _PdfStrings _pdfStrings(String localeCode, String type) {
    switch (localeCode) {
      case 'ar':
        return _PdfStrings(
          title: type == 'quote' ? 'عرض سعر' : 'فاتورة',
          numberLabel: 'الرقم',
          dateLabel: 'التاريخ',
          dueLabel: 'الاستحقاق',
          statusLabel: 'الحالة',
          billToLabel: 'إلى',
          descriptionLabel: 'الوصف',
          quantityLabel: 'الكمية',
          unitPriceLabel: 'سعر الوحدة',
          subtotalLabel: 'الإجمالي الفرعي',
          taxLabel: 'الضريبة',
          discountLabel: 'الخصم',
          totalLabel: 'الإجمالي',
          notesLabel: 'ملاحظات',
        );
      case 'fr':
        return _PdfStrings(
          title: type == 'quote' ? 'Devis' : 'Facture',
          numberLabel: 'Numéro',
          dateLabel: 'Date',
          dueLabel: 'Échéance',
          statusLabel: 'Statut',
          billToLabel: 'Facturé à',
          descriptionLabel: 'Description',
          quantityLabel: 'Qté',
          unitPriceLabel: 'Prix unitaire',
          subtotalLabel: 'Sous-total',
          taxLabel: 'Taxe',
          discountLabel: 'Remise',
          totalLabel: 'Total',
          notesLabel: 'Notes',
        );
      default:
        return _PdfStrings(
          title: type == 'quote' ? 'Quote' : 'Invoice',
          numberLabel: 'Number',
          dateLabel: 'Date',
          dueLabel: 'Due',
          statusLabel: 'Status',
          billToLabel: 'Bill To',
          descriptionLabel: 'Description',
          quantityLabel: 'Qty',
          unitPriceLabel: 'Unit Price',
          subtotalLabel: 'Subtotal',
          taxLabel: 'Tax',
          discountLabel: 'Discount',
          totalLabel: 'Total',
          notesLabel: 'Notes',
        );
    }
  }

  String _localizedStatus(String localeCode, String status) {
    switch (localeCode) {
      case 'ar':
        switch (status) {
          case 'paid':
            return 'مدفوع';
          case 'unpaid':
            return 'غير مدفوع';
          default:
            return 'مسودة';
        }
      case 'fr':
        switch (status) {
          case 'paid':
            return 'Payée';
          case 'unpaid':
            return 'Impayée';
          default:
            return 'Brouillon';
        }
      default:
        switch (status) {
          case 'paid':
            return 'Paid';
          case 'unpaid':
            return 'Unpaid';
          default:
            return 'Draft';
        }
    }
  }
}

class _PdfStrings {
  final String title;
  final String numberLabel;
  final String dateLabel;
  final String dueLabel;
  final String statusLabel;
  final String billToLabel;
  final String descriptionLabel;
  final String quantityLabel;
  final String unitPriceLabel;
  final String subtotalLabel;
  final String taxLabel;
  final String discountLabel;
  final String totalLabel;
  final String notesLabel;

  _PdfStrings({
    required this.title,
    required this.numberLabel,
    required this.dateLabel,
    required this.dueLabel,
    required this.statusLabel,
    required this.billToLabel,
    required this.descriptionLabel,
    required this.quantityLabel,
    required this.unitPriceLabel,
    required this.subtotalLabel,
    required this.taxLabel,
    required this.discountLabel,
    required this.totalLabel,
    required this.notesLabel,
  });
}