import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  ConsumerState createState() => _InvoicePreviewScreenState();
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
    final rawNumber =
        widget.invoice.invoiceNumber.trim().isEmpty ? typePrefix : widget.invoice.invoiceNumber;
    final safeNumber = _sanitizeFileNamePart(rawNumber);
    return '$typePrefix-$safeNumber.pdf';
  }

  String _documentLabel(AppLocalizations t) {
    return widget.invoice.type == 'quote' ? t.quotePreviewTitle : t.invoicePreviewTitle;
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

  String _formatAmount(double value, String currency) {
    return '${value.toStringAsFixed(2)} $currency';
  }

  Widget _buildHeaderCard(AppLocalizations t, String currency) {
    final locale = Localizations.localeOf(context).languageCode;
    final issueDate = DateFormat.yMMMd(locale).format(widget.invoice.issueDate);
    final dueDate = DateFormat.yMMMd(locale).format(widget.invoice.dueDate);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.invoice.invoiceNumber,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.client.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
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
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PreviewMetaChip(
                  icon: Icons.calendar_today_outlined,
                  label: '${t.date}: $issueDate',
                ),
                _PreviewMetaChip(
                  icon: Icons.event_outlined,
                  label: '${t.dueDate}: $dueDate',
                ),
                _PreviewMetaChip(
                  icon: Icons.picture_as_pdf_outlined,
                  label: _buildPdfFileName(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.invoice.type == 'invoice'
                  ? Row(
                      children: [
                        Expanded(
                          child: _PreviewAmountTile(
                            label: t.total,
                            value: _formatAmount(widget.invoice.total, currency),
                            emphasize: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PreviewAmountTile(
                            label: t.paidAmount,
                            value: _formatAmount(widget.invoice.paidAmount, currency),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PreviewAmountTile(
                            label: t.remainingAmount,
                            value: _formatAmount(widget.invoice.remainingAmount, currency),
                            emphasize: widget.invoice.remainingAmount > 0,
                          ),
                        ),
                      ],
                    )
                  : _PreviewAmountTile(
                      label: t.total,
                      value: _formatAmount(widget.invoice.total, currency),
                      emphasize: true,
                    ),
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

  Widget _buildWebFallback(AppLocalizations t, String currency) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
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
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.invoice.type == 'invoice'
                        ? Row(
                            children: [
                              Expanded(
                                child: _PreviewAmountTile(
                                  label: t.total,
                                  value: _formatAmount(widget.invoice.total, currency),
                                  emphasize: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _PreviewAmountTile(
                                  label: t.paidAmount,
                                  value: _formatAmount(widget.invoice.paidAmount, currency),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _PreviewAmountTile(
                                  label: t.remainingAmount,
                                  value: _formatAmount(widget.invoice.remainingAmount, currency),
                                  emphasize: widget.invoice.remainingAmount > 0,
                                ),
                              ),
                            ],
                          )
                        : _PreviewAmountTile(
                            label: t.total,
                            value: _formatAmount(widget.invoice.total, currency),
                            emphasize: true,
                          ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pdfBytes == null || _isExporting ? null : _exportPdf,
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

  Widget _buildBody(AppLocalizations t, String currency) {
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
      return _buildWebFallback(t, currency);
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
    final appSettings = ref.watch(appSettingsProvider);
    final currency = appSettings.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(_documentLabel(t)),
      ),
      body: Column(
        children: [
          _buildHeaderCard(t, currency),
          _buildActionButtons(t),
          Expanded(
            child: _buildBody(t, currency),
          ),
        ],
      ),
    );
  }
}

class _PreviewMetaChip extends StatelessWidget {
  const _PreviewMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewAmountTile extends StatelessWidget {
  const _PreviewAmountTile({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: emphasize ? colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}