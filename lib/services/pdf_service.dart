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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          invoice.type == 'quote' ? 'QUOTE' : 'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 16),
                        pw.Text('No: ${invoice.invoiceNumber}'),
                        pw.Text('Date: ${invoice.issueDate.toLocal().toString().split(' ').first}'),
                        pw.Text('Due: ${invoice.dueDate.toLocal().toString().split(' ').first}'),
                        pw.Text('Status: ${invoice.status}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          business.name,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (business.email.isNotEmpty) pw.Text(business.email),
                        if (business.phone.isNotEmpty) pw.Text(business.phone),
                        if (business.address.isNotEmpty) pw.Text(business.address),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),
                pw.Text(
                  'Bill To',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(client.name),
                if (client.email.isNotEmpty) pw.Text(client.email),
                if (client.phone.isNotEmpty) pw.Text(client.phone),
                if (client.address.isNotEmpty) pw.Text(client.address),
                pw.SizedBox(height: 32),
                pw.TableHelper.fromTextArray(
                  headers: const ['Description', 'Qty', 'Unit Price', 'Total'],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
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
                pw.SizedBox(height: 24),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.SizedBox(
                    width: 220,
                    child: pw.Column(
                      children: [
                        _summaryRow(
                          'Subtotal',
                          '${invoice.subtotal.toStringAsFixed(2)} $currency',
                        ),
                        _summaryRow(
                          'Tax',
                          '${invoice.taxAmount.toStringAsFixed(2)} $currency',
                        ),
                        _summaryRow(
                          'Discount',
                          '${invoice.discount.toStringAsFixed(2)} $currency',
                        ),
                        pw.Divider(),
                        _summaryRow(
                          'Total',
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
                    'Notes',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(invoice.notes),
                ],
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _summaryRow(String label, String value, {bool isBold = false}) {
    final style = isBold
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
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
}