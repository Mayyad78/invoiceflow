import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
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

    final arabicFontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(arabicFontData);

    final baseFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    final baseTextStyle = pw.TextStyle(
      font: baseFont,
      fontFallback: [arabicFont],
      fontSize: 11,
    );

    final boldTextStyle = pw.TextStyle(
      font: boldFont,
      fontFallback: [arabicFont],
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
    );

    final titleTextStyle = pw.TextStyle(
      font: boldFont,
      fontFallback: [arabicFont],
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
    );

    final businessTitleStyle = pw.TextStyle(
      font: boldFont,
      fontFallback: [arabicFont],
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );

    final sectionTitleStyle = pw.TextStyle(
      font: boldFont,
      fontFallback: [arabicFont],
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    );

    final textDirection =
        localeCode == 'ar' ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final crossAlign = localeCode == 'ar'
        ? pw.CrossAxisAlignment.end
        : pw.CrossAxisAlignment.start;
    final textAlign =
        localeCode == 'ar' ? pw.TextAlign.right : pw.TextAlign.left;
    final summaryAlign =
        localeCode == 'ar' ? pw.Alignment.centerLeft : pw.Alignment.centerRight;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection: textDirection,
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: localeCode == 'ar'
                  ? [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              business.name.isEmpty
                                  ? 'InvoiceFlow'
                                  : business.name,
                              style: businessTitleStyle,
                              textAlign: pw.TextAlign.right,
                            ),
                            if (business.email.isNotEmpty) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                business.email,
                                style: baseTextStyle,
                                textAlign: pw.TextAlign.right,
                              ),
                            ],
                            if (business.phone.isNotEmpty) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                business.phone,
                                style: baseTextStyle,
                                textAlign: pw.TextAlign.right,
                              ),
                            ],
                            if (business.address.isNotEmpty) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                business.address,
                                style: baseTextStyle,
                                textAlign: pw.TextAlign.right,
                              ),
                            ],
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 24),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              strings.title,
                              style: titleTextStyle,
                              textAlign: pw.TextAlign.left,
                            ),
                            pw.SizedBox(height: 16),
                            _infoLine(
                              strings.numberLabel,
                              invoice.invoiceNumber,
                              baseStyle: baseTextStyle,
                              boldStyle: boldTextStyle,
                              localeCode: localeCode,
                            ),
                            _infoLine(
                              strings.dateLabel,
                              invoice.issueDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                              baseStyle: baseTextStyle,
                              boldStyle: boldTextStyle,
                              localeCode: localeCode,
                            ),
                            _infoLine(
                              strings.dueLabel,
                              invoice.dueDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                              baseStyle: baseTextStyle,
                              boldStyle: boldTextStyle,
                              localeCode: localeCode,
                            ),
                            _infoLine(
                              strings.statusLabel,
                              _localizedStatus(localeCode, invoice.status),
                              baseStyle: baseTextStyle,
                              boldStyle: boldTextStyle,
                              localeCode: localeCode,
                            ),
                          ],
                        ),
                      ),
                    ]
                  : [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              strings.title,
                              style: titleTextStyle,
                            ),
                            pw.SizedBox(height: 16),
                            _infoLine(
                              strings.numberLabel,
                              invoice.invoiceNumber,
                              baseStyle: baseTextStyle,
                              boldStyle: boldTextStyle,
                              localeCode: localeCode,
                            ),
                            _infoLine(
                              strings.dateLabel,
                              invoice.issueDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                              baseStyle: baseTextStyle,
                              boldStyle: boldTextStyle,
                              localeCode: localeCode,
                            ),
                            _infoLine(
                              strings.dueLabel,
                              invoice.dueDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                              baseStyle: baseTextStyle,
                              boldStyle: boldTextStyle,
                              localeCode: localeCode,
                            ),
                            _infoLine(
                              strings.statusLabel,
                              _localizedStatus(localeCode, invoice.status),
                              baseStyle: baseTextStyle,
                              boldStyle: boldTextStyle,
                              localeCode: localeCode,
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
                              business.name.isEmpty
                                  ? 'InvoiceFlow'
                                  : business.name,
                              style: businessTitleStyle,
                              textAlign: pw.TextAlign.right,
                            ),
                            if (business.email.isNotEmpty) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                business.email,
                                style: baseTextStyle,
                                textAlign: pw.TextAlign.right,
                              ),
                            ],
                            if (business.phone.isNotEmpty) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                business.phone,
                                style: baseTextStyle,
                                textAlign: pw.TextAlign.right,
                              ),
                            ],
                            if (business.address.isNotEmpty) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                business.address,
                                style: baseTextStyle,
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
                crossAxisAlignment: crossAlign,
                children: [
                  pw.Text(
                    strings.billToLabel,
                    style: sectionTitleStyle,
                    textAlign: textAlign,
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(client.name, style: baseTextStyle, textAlign: textAlign),
                  if (client.email.isNotEmpty)
                    pw.Text(client.email, style: baseTextStyle, textAlign: textAlign),
                  if (client.phone.isNotEmpty)
                    pw.Text(client.phone, style: baseTextStyle, textAlign: textAlign),
                  if (client.address.isNotEmpty)
                    pw.Text(client.address, style: baseTextStyle, textAlign: textAlign),
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
                font: boldFont,
                fontFallback: [arabicFont],
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey700,
              ),
              cellStyle: pw.TextStyle(
                font: baseFont,
                fontFallback: [arabicFont],
              ),
              cellAlignment: localeCode == 'ar'
                  ? pw.Alignment.centerRight
                  : pw.Alignment.centerLeft,
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
              alignment: summaryAlign,
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
                      baseStyle: baseTextStyle,
                      boldStyle: boldTextStyle,
                      localeCode: localeCode,
                    ),
                    _summaryRow(
                      strings.taxLabel,
                      '${invoice.taxAmount.toStringAsFixed(2)} $currency',
                      baseStyle: baseTextStyle,
                      boldStyle: boldTextStyle,
                      localeCode: localeCode,
                    ),
                    _summaryRow(
                      strings.discountLabel,
                      '${invoice.discount.toStringAsFixed(2)} $currency',
                      baseStyle: baseTextStyle,
                      boldStyle: boldTextStyle,
                      localeCode: localeCode,
                    ),
                    pw.Divider(),
                    _summaryRow(
                      strings.totalLabel,
                      '${invoice.total.toStringAsFixed(2)} $currency',
                      baseStyle: baseTextStyle,
                      boldStyle: boldTextStyle,
                      localeCode: localeCode,
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
                style: sectionTitleStyle,
                textAlign: textAlign,
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                invoice.notes,
                style: baseTextStyle,
                textAlign: textAlign,
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _infoLine(
    String label,
    String value, {
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    required String localeCode,
  }) {
    if (localeCode == 'ar') {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                value,
                style: baseStyle,
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Text(
              ' :$label',
              style: boldStyle,
              textAlign: pw.TextAlign.right,
            ),
          ],
        ),
      );
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text('$label: ', style: boldStyle),
          pw.Expanded(
            child: pw.Text(value, style: baseStyle),
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryRow(
    String label,
    String value, {
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    required String localeCode,
    bool isBold = false,
  }) {
    final labelStyle = isBold ? boldStyle : baseStyle;
    final valueStyle = isBold ? boldStyle : baseStyle;

    if (localeCode == 'ar') {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(value, style: valueStyle),
            pw.Text(label, style: labelStyle),
          ],
        ),
      );
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: labelStyle),
          pw.Text(value, style: valueStyle),
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