import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/pdf_service_provider.dart';

class InvoicePreviewScreen extends ConsumerStatefulWidget {
  const InvoicePreviewScreen({
    super.key,
    required this.invoice,
    required this.client,
  });

  final InvoiceModel invoice;
  final ClientModel client;

  @override
  ConsumerState<InvoicePreviewScreen> createState() =>
      _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends ConsumerState<InvoicePreviewScreen> {
  Uint8List? _pdfBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPdf();
    });
  }

  Future<void> _loadPdf() async {
    try {
      final localeCode =
          Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';

      final business = ref.read(businessProfileProvider);
      final appSettings = ref.read(appSettingsProvider);
      final pdfService = ref.read(pdfServiceProvider);

      final bytes = await pdfService.generateInvoicePdf(
        invoice: widget.invoice,
        client: widget.client,
        business: business,
        localeCode: localeCode,
        currency: appSettings.currency,
      );

      if (!mounted) return;

      setState(() {
        _pdfBytes = bytes;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;

    final fileName =
        '${widget.invoice.type == 'quote' ? 'quote' : 'invoice'}-${widget.invoice.invoiceNumber}.pdf';

    await Share.shareXFiles(
      [
        XFile.fromData(
          _pdfBytes!,
          name: fileName,
          mimeType: 'application/pdf',
        ),
      ],
      text: fileName,
    );
  }

  Future<void> _printPdf() async {
    if (_pdfBytes == null) return;

    await Printing.layoutPdf(
      onLayout: (_) async => _pdfBytes!,
    );
  }

  Future<void> _downloadPdf() async {
    if (_pdfBytes == null) return;

    final fileName =
        '${widget.invoice.type == 'quote' ? 'quote' : 'invoice'}-${widget.invoice.invoiceNumber}.pdf';

    await Printing.sharePdf(
      bytes: _pdfBytes!,
      filename: fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final title = widget.invoice.type == 'quote'
        ? t.quotePreviewTitle
        : t.invoicePreviewTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _pdfBytes == null ? null : _sharePdf,
            icon: const Icon(Icons.share),
            tooltip: t.share,
          ),
          IconButton(
            onPressed: _pdfBytes == null ? null : _printPdf,
            icon: const Icon(Icons.print),
            tooltip: t.print,
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('PDF error: $_error'),
              ),
            )
          : _pdfBytes == null
              ? const Center(child: CircularProgressIndicator())
              : kIsWeb
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.picture_as_pdf, size: 64),
                                  const SizedBox(height: 16),
                                  Text(
                                    title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 12),
                                  Text('PDF bytes: ${_pdfBytes!.length}'),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _printPdf,
                                      icon: const Icon(Icons.print),
                                      label: Text(t.print),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _sharePdf,
                                      icon: const Icon(Icons.share),
                                      label: Text(t.share),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _downloadPdf,
                                      icon: const Icon(Icons.download),
                                      label: Text(t.downloadPdf),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : PdfPreview(
                      build: (format) async => _pdfBytes!,
                      allowPrinting: true,
                      allowSharing: false,
                      canChangePageFormat: false,
                      canDebug: false,
                    ),
    );
  }
}