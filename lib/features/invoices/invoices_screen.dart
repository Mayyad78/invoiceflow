import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/invoices_provider.dart';
import '../../utils/invoice_status_localizer.dart';
import 'create_invoice_screen.dart';
import 'invoice_preview_screen.dart';
import 'templates_screen.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key, this.type = 'invoice'});

  final String type;

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    AppLocalizations t,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.confirmDelete),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmConvertQuote(BuildContext context, AppLocalizations t) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.confirmConvertQuote),
        content: Text(t.confirmConvertQuoteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.convertToInvoice),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptTemplateName({
    required AppLocalizations t,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t.templateName),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: t.templateName,
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                ),
                onChanged: (_) {
                  if (errorText != null) {
                    setDialogState(() {
                      errorText = null;
                    });
                  }
                },
                onSubmitted: (_) {
                  final value = controller.text.trim();
                  if (value.isEmpty) {
                    setDialogState(() {
                      errorText = t.requiredField;
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop(value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(t.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isEmpty) {
                      setDialogState(() {
                        errorText = t.requiredField;
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(value);
                  },
                  child: Text(t.save),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> _convertQuoteToInvoice(
    BuildContext context,
    AppLocalizations t,
    InvoiceModel quote,
  ) async {
    if (quote.isConvertedQuote) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.quoteAlreadyConverted)),
      );
      return;
    }

    final confirmed = await _confirmConvertQuote(context, t);
    if (confirmed != true) return;

    final numberingNotifier = ref.read(appSettingsProvider.notifier);
    final invoiceNumber =
        await numberingNotifier.consumeNextDocumentNumber('invoice');

    final now = DateTime.now();
    final newInvoiceId = const Uuid().v4();

    final invoice = InvoiceModel(
      id: newInvoiceId,
      invoiceNumber: invoiceNumber,
      clientId: quote.clientId,
      issueDate: now,
      dueDate: now.add(const Duration(days: 7)),
      items: List.from(quote.items),
      taxPercent: quote.taxPercent,
      discount: quote.discount,
      notes: quote.notes,
      status: 'draft',
      type: 'invoice',
      paidAmount: 0,
      convertedInvoiceId: null,
      isTemplate: false,
      templateName: null,
    );

    final updatedQuote = quote.copyWith(
      convertedInvoiceId: newInvoiceId,
    );

    await ref.read(invoicesProvider.notifier).addInvoice(invoice);
    await ref.read(invoicesProvider.notifier).updateInvoice(updatedQuote);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.quoteConverted)),
    );
  }

  void _openDuplicateDocument(InvoiceModel invoice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateInvoiceScreen(
          type: widget.type,
          invoice: invoice,
          isDuplicate: true,
        ),
      ),
    );
  }

  Future<void> _saveAsTemplate(AppLocalizations t, InvoiceModel invoice) async {
    final templateName = await _promptTemplateName(
      t: t,
      initialValue: invoice.templateName,
    );

    if (!mounted) return;

    if (templateName == null || templateName.trim().isEmpty) {
      return;
    }

    final template = invoice.copyWith(
      id: const Uuid().v4(),
      invoiceNumber: '',
      status: 'draft',
      paidAmount: 0,
      isTemplate: true,
      templateName: templateName,
      clearConvertedInvoiceId: true,
    );

    await ref.read(invoicesProvider.notifier).addInvoice(template);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.templateSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final invoices = ref
        .watch(invoicesProvider)
        .where(
          (invoice) =>
              invoice.type == widget.type && invoice.isTemplate == false,
        )
        .toList();
    final clients = ref.watch(clientsProvider);
    final query = _searchController.text.trim().toLowerCase();

    ClientModel? findClient(String clientId) {
      try {
        return clients.firstWhere((client) => client.id == clientId);
      } catch (_) {
        return null;
      }
    }

    final filteredInvoices = invoices.where((invoice) {
      final client = findClient(invoice.clientId);
      final clientName = client?.name.toLowerCase() ?? '';

      if (query.isEmpty) return true;

      return invoice.invoiceNumber.toLowerCase().contains(query) ||
          clientName.contains(query) ||
          normalizeInvoiceStatus(invoice.status).contains(query);
    }).toList()
      ..sort((a, b) {
        final dateCompare = b.issueDate.compareTo(a.issueDate);
        if (dateCompare != 0) return dateCompare;
        return b.invoiceNumber.compareTo(a.invoiceNumber);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 'quote' ? t.quotePreviewTitle : t.invoicesTitle,
        ),
        actions: [
          IconButton(
            tooltip: t.templates,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TemplatesScreen(type: widget.type),
                ),
              );
            },
            icon: const Icon(Icons.bookmarks_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t.searchInvoices,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                        tooltip: t.clearSearch,
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: invoices.isEmpty
                ? _EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: t.noInvoicesYet,
                    subtitle: t.startByCreatingInvoice,
                  )
                : filteredInvoices.isEmpty
                    ? _EmptyState(
                        icon: Icons.search_off,
                        title: t.noResultsFound,
                        subtitle: t.searchInvoices,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredInvoices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final invoice = filteredInvoices[index];
                          final client = findClient(invoice.clientId);

                          final dateText = DateFormat.yMMMd(
                            Localizations.localeOf(context).languageCode,
                          ).format(invoice.issueDate);

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(invoice.invoiceNumber),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        if (client != null)
                                          Text('${t.client}: ${client.name}'),
                                        const SizedBox(height: 4),
                                        Text('${t.date}: $dateText'),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${t.total}: ${invoice.total.toStringAsFixed(2)}',
                                        ),
                                        if (invoice.type == 'invoice') ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${t.paidAmount}: ${invoice.paidAmount.toStringAsFixed(2)}',
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${t.remainingAmount}: ${invoice.remainingAmount.toStringAsFixed(2)}',
                                          ),
                                        ],
                                        if (invoice.type == 'quote' &&
                                            invoice.isConvertedQuote) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            t.quoteAlreadyConverted,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        _StatusBadge(
                                          label: localizeInvoiceStatus(
                                            t,
                                            invoice.status,
                                          ),
                                          color: _statusColor(invoice.status),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: [
                                          if (widget.type == 'quote' &&
                                              !invoice.isConvertedQuote)
                                            TextButton.icon(
                                              onPressed: () =>
                                                  _convertQuoteToInvoice(
                                                context,
                                                t,
                                                invoice,
                                              ),
                                              icon: const Icon(
                                                Icons.transform_outlined,
                                              ),
                                              label: Text(t.convertToInvoice),
                                            ),
                                          TextButton.icon(
                                            onPressed: () =>
                                                _openDuplicateDocument(invoice),
                                            icon:
                                                const Icon(Icons.copy_outlined),
                                            label: Text(t.duplicate),
                                          ),
                                          TextButton.icon(
                                            onPressed: () =>
                                                _saveAsTemplate(t, invoice),
                                            icon: const Icon(
                                              Icons.bookmark_border,
                                            ),
                                            label: Text(t.saveAsTemplate),
                                          ),
                                          TextButton.icon(
                                            onPressed: client == null
                                                ? null
                                                : () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            CreateInvoiceScreen(
                                                          type: widget.type,
                                                          invoice: invoice,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                            label: Text(t.edit),
                                          ),
                                          TextButton.icon(
                                            onPressed: client == null
                                                ? null
                                                : () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            InvoicePreviewScreen(
                                                          invoice: invoice,
                                                          client: client,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            icon: const Icon(
                                              Icons.visibility_outlined,
                                            ),
                                            label: Text(t.preview),
                                          ),
                                          TextButton.icon(
                                            onPressed: () async {
                                              final confirmed =
                                                  await _confirmDelete(
                                                context,
                                                t,
                                                t.deleteInvoiceMessage,
                                              );
                                              if (confirmed == true) {
                                                await ref
                                                    .read(
                                                      invoicesProvider.notifier,
                                                    )
                                                    .deleteInvoice(invoice.id);
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            label: Text(t.delete),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateInvoiceScreen(type: widget.type),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          widget.type == 'quote' ? t.newQuote : t.newInvoice,
        ),
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (normalizeInvoiceStatus(status)) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.red;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}