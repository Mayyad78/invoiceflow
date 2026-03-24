import 'dart:convert';
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
    final isArabic = localeCode == 'ar';

    final arabicFontData =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(arabicFontData);

    final baseFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    final baseTextStyle = pw.TextStyle(
      font: baseFont,
      fontFallback: [arabicFont],
      fontSize: 10.5,
      lineSpacing: 2,
    );

    final mutedTextStyle = pw.TextStyle(
      font: baseFont,
      fontFallback: [arabicFont],
      fontSize: 9.5,
      color: PdfColors.blueGrey700,
      lineSpacing: 2,
    );

    final boldTextStyle = pw.TextStyle(
      font: boldFont,
      fontFallback: [arabicFont],
      fontSize: 10.5,
      fontWeight: pw.FontWeight.bold,
    );

    final titleTextStyle = pw.TextStyle(
      font: boldFont,
      fontFallback: [arabicFont],
      fontSize: 26,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueGrey900,
    );

    final businessTitleStyle = pw.TextStyle(
      font: boldFont,
      fontFallback: [arabicFont],
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueGrey900,
    );

    final sectionTitleStyle = pw.TextStyle(
      font: boldFont,
      fontFallback: [arabicFont],
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueGrey900,
    );

    final textDirection =
        isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    final clientCrossAlign =
        isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start;
    final clientTextAlign =
        isArabic ? pw.TextAlign.right : pw.TextAlign.left;

    final summaryAlign =
        isArabic ? pw.Alignment.centerLeft : pw.Alignment.centerRight;

    final logoBytes = _decodeLogoBytes(business.logoBase64);
    final logoProvider =
        logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 28),
        textDirection: textDirection,
        build: (context) {
          return [
            _buildHeader(
              localeCode: localeCode,
              strings: strings,
              invoice: invoice,
              business: business,
              logoProvider: logoProvider,
              titleTextStyle: titleTextStyle,
              businessTitleStyle: businessTitleStyle,
              baseTextStyle: baseTextStyle,
              mutedTextStyle: mutedTextStyle,
              boldTextStyle: boldTextStyle,
            ),
            pw.SizedBox(height: 22),
            _buildClientCard(
              strings: strings,
              client: client,
              crossAlign: clientCrossAlign,
              textAlign: clientTextAlign,
              sectionTitleStyle: sectionTitleStyle,
              baseTextStyle: baseTextStyle,
            ),
            pw.SizedBox(height: 22),
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
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey800,
              ),
              headerHeight: 28,
              cellStyle: pw.TextStyle(
                font: baseFont,
                fontFallback: [arabicFont],
                fontSize: 10,
              ),
              cellAlignment: isArabic
                  ? pw.Alignment.centerRight
                  : pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.6,
                ),
                bottom: pw.BorderSide(
                  color: PdfColors.grey400,
                  width: 0.8,
                ),
              ),
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
            pw.SizedBox(height: 22),
            pw.Align(
              alignment: summaryAlign,
              child: pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.blueGrey100),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
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
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 6),
                      child: pw.Divider(color: PdfColors.blueGrey100),
                    ),
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
              pw.SizedBox(height: 22),
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
                  crossAxisAlignment: clientCrossAlign,
                  children: [
                    pw.Text(
                      strings.notesLabel,
                      style: sectionTitleStyle,
                      textAlign: clientTextAlign,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      invoice.notes,
                      style: baseTextStyle,
                      textAlign: clientTextAlign,
                    ),
                  ],
                ),
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader({
    required String localeCode,
    required _PdfStrings strings,
    required InvoiceModel invoice,
    required BusinessProfileModel business,
    required pw.MemoryImage? logoProvider,
    required pw.TextStyle titleTextStyle,
    required pw.TextStyle businessTitleStyle,
    required pw.TextStyle baseTextStyle,
    required pw.TextStyle mutedTextStyle,
    required pw.TextStyle boldTextStyle,
  }) {
    final isArabic = localeCode == 'ar';

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.blueGrey100),
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(12),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Align(
              alignment: pw.Alignment.topLeft,
              child: _buildDocumentBlock(
                localeCode: localeCode,
                strings: strings,
                invoice: invoice,
                titleTextStyle: titleTextStyle,
                baseTextStyle: baseTextStyle,
                boldTextStyle: boldTextStyle,
                isArabic: isArabic,
              ),
            ),
          ),
          pw.SizedBox(width: 18),
          pw.Expanded(
            flex: 6,
            child: pw.Align(
              alignment: pw.Alignment.topRight,
              child: _buildBusinessBlock(
                business: business,
                logoProvider: logoProvider,
                isArabic: isArabic,
                businessTitleStyle: businessTitleStyle,
                baseTextStyle: baseTextStyle,
                mutedTextStyle: mutedTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBusinessBlock({
    required BusinessProfileModel business,
    required pw.MemoryImage? logoProvider,
    required bool isArabic,
    required pw.TextStyle businessTitleStyle,
    required pw.TextStyle baseTextStyle,
    required pw.TextStyle mutedTextStyle,
  }) {
    return pw.Container(
      width: 220,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          if (logoProvider != null)
            pw.Container(
              width: 110,
              height: 90,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                border: pw.Border.all(color: PdfColors.blueGrey100),
                borderRadius: const pw.BorderRadius.all(
                  pw.Radius.circular(12),
                ),
              ),
              alignment: pw.Alignment.center,
              child: pw.Image(
                logoProvider,
                fit: pw.BoxFit.contain,
              ),
            ),
          if (logoProvider != null) pw.SizedBox(height: 12),
          pw.Text(
            business.name.isEmpty ? 'InvoiceFlow' : business.name,
            style: businessTitleStyle,
            textAlign: pw.TextAlign.right,
          ),
          if (business.email.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              business.email,
              style: mutedTextStyle,
              textAlign: pw.TextAlign.right,
            ),
          ],
          if (business.phone.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              business.phone,
              style: mutedTextStyle,
              textAlign: pw.TextAlign.right,
            ),
          ],
          if (business.address.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              business.address,
              style: baseTextStyle,
              textAlign: pw.TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildDocumentBlock({
    required String localeCode,
    required _PdfStrings strings,
    required InvoiceModel invoice,
    required pw.TextStyle titleTextStyle,
    required pw.TextStyle baseTextStyle,
    required pw.TextStyle boldTextStyle,
    required bool isArabic,
  }) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            strings.title,
            style: titleTextStyle,
            textAlign: pw.TextAlign.left,
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(
                pw.Radius.circular(10),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _infoLine(
                  strings.numberLabel,
                  invoice.invoiceNumber,
                  baseStyle: baseTextStyle,
                  boldStyle: boldTextStyle,
                  localeCode: localeCode,
                ),
                _infoLine(
                  strings.dateLabel,
                  invoice.issueDate.toLocal().toString().split(' ').first,
                  baseStyle: baseTextStyle,
                  boldStyle: boldTextStyle,
                  localeCode: localeCode,
                ),
                _infoLine(
                  strings.dueLabel,
                  invoice.dueDate.toLocal().toString().split(' ').first,
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
        ],
      ),
    );
  }

  pw.Widget _buildClientCard({
    required _PdfStrings strings,
    required ClientModel client,
    required pw.CrossAxisAlignment crossAlign,
    required pw.TextAlign textAlign,
    required pw.TextStyle sectionTitleStyle,
    required pw.TextStyle baseTextStyle,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(10),
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
            pw.Text(
              client.address,
              style: baseTextStyle,
              textAlign: textAlign,
            ),
        ],
      ),
    );
  }

  Uint8List? _decodeLogoBytes(String? logoBase64) {
    if (logoBase64 == null || logoBase64.isEmpty) {
      return null;
    }

    try {
      return base64Decode(logoBase64);
    } catch (_) {
      return null;
    }
  }

  pw.Widget _infoLine(
    String label,
    String value, {
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    required String localeCode,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: boldStyle, textAlign: pw.TextAlign.left),
          pw.Text(': ', style: boldStyle, textAlign: pw.TextAlign.left),
          pw.Expanded(
            child: pw.Text(
              value,
              style: baseStyle,
              textAlign: localeCode == 'ar'
                  ? pw.TextAlign.right
                  : pw.TextAlign.left,
            ),
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
          case 'partial':
          case 'partially_paid':
            return 'مدفوع جزئياً';
          default:
            return 'مسودة';
        }

      case 'fr':
        switch (status) {
          case 'paid':
            return 'Payée';
          case 'unpaid':
            return 'Impayée';
          case 'partial':
          case 'partially_paid':
            return 'Partiellement payée';
          default:
            return 'Brouillon';
        }

      default:
        switch (status) {
          case 'paid':
            return 'Paid';
          case 'unpaid':
            return 'Unpaid';
          case 'partial':
          case 'partially_paid':
            return 'Partially Paid';
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