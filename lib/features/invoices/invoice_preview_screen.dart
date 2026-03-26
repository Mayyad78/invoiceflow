import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

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
  bool _isLoading = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPdf();
    });
  }

  String _sanitizeFileNamePart(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '-')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _buildPdfFileName() {
    final typePrefix = widget.invoice.type == 'quote' ? 'quote' : 'invoice';
    final rawNumber = widget.invoice.invoiceNumber.trim().isEmpty
        ? typePrefix
        : widget.invoice.invoiceNumber;
    final safeNumber = _sanitizeFileNamePart(rawNumber);
    return '$typePrefix-$safeNumber.pdf';
  }

  String _documentLabel(AppLocalizations t) {
    return widget.invoice.type == 'quote'
        ? t.quotePreviewTitle
        : t.invoicePreviewTitle;
  }

  String _statusLabel(AppLocalizations t) {
    switch (widget.invoice.status) {
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

  Future<void> _loadPdf() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final localeCode = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
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
        _pdfBytes = null;
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportPdf() async {
    if (_pdfBytes == null || _isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      await Printing.sharePdf(
        bytes: _pdfBytes!,
        filename: _buildPdfFileName(),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
      });
    }
  }

  Widget _buildHeaderCard(AppLocalizations t) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.invoice.invoiceNumber,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(t),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoLine(
                    label: t.client,
                    value: widget.client.name,
                  ),
                ),
                Expanded(
                  child: _InfoLine(
                    label: t.total,
                    value: widget.invoice.total.toStringAsFixed(2),
                  ),
                ),
              ],
            ),
            if (widget.invoice.type == 'invoice') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoLine(
                      label: t.paidAmount,
                      value: widget.invoice.paidAmount.toStringAsFixed(2),
                    ),
                  ),
                  Expanded(
                    child: _InfoLine(
                      label: t.remainingAmount,
                      value: widget.invoice.remainingAmount.toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            _InfoLine(
              label: t.downloadPdf,
              value: _buildPdfFileName(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: (_pdfBytes == null || _isExporting) ? null : _exportPdf,
            icon: _isExporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(t.exportPdf),
          ),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _loadPdf,
            icon: const Icon(Icons.refresh),
            label: Text(t.refreshPreview),
          ),
        ],
      ),
    );
  }

  Widget _buildWebFallback(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _documentLabel(t),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _buildPdfFileName(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${t.total}: ${widget.invoice.total.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                  ),
                  if (widget.invoice.type == 'invoice') ...[
                    const SizedBox(height: 8),
                    Text(
                      '${t.paidAmount}: ${widget.invoice.paidAmount.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${t.remainingAmount}: ${widget.invoice.remainingAmount.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pdfBytes == null || _isExporting
                          ? null
                          : _exportPdf,
                      icon: const Icon(Icons.download),
                      label: Text(t.exportPdf),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations t) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      t.previewError,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadPdf,
                      icon: const Icon(Icons.refresh),
                      label: Text(t.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoading || _pdfBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (kIsWeb) {
      return _buildWebFallback(t);
    }

    return PdfPreview(
      build: (format) async => _pdfBytes!,
      allowPrinting: true,
      allowSharing: true,
      canChangePageFormat: false,
      canDebug: false,
      pdfFileName: _buildPdfFileName(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_documentLabel(t)),
      ),
      body: Column(
        children: [
          _buildHeaderCard(t),
          _buildActionButtons(t),
          Expanded(child: _buildBody(t)),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}