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

  static const _actionConvert = 'convert';
  static const _actionSaveTemplate = 'saveTemplate';
  static const _actionDelete = 'delete';

  String? _statusFilter;

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
      isFavoriteTemplate: false,
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

  void _openCreateDocument() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateInvoiceScreen(type: widget.type),
      ),
    );
  }

  void _openTemplates() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TemplatesScreen(type: widget.type),
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
      isFavoriteTemplate: false,
      clearConvertedInvoiceId: true,
    );

    await ref.read(invoicesProvider.notifier).addInvoice(template);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.templateSaved)),
    );
  }

  Future<void> _handleMenuAction({
    required BuildContext context,
    required AppLocalizations t,
    required InvoiceModel invoice,
    required String action,
  }) async {
    switch (action) {
      case _actionConvert:
        await _convertQuoteToInvoice(context, t, invoice);
        break;
      case _actionSaveTemplate:
        await _saveAsTemplate(t, invoice);
        break;
      case _actionDelete:
        final confirmed = await _confirmDelete(
          context,
          t,
          t.deleteInvoiceMessage,
        );
        if (confirmed == true) {
          await ref.read(invoicesProvider.notifier).deleteInvoice(invoice.id);
        }
        break;
    }
  }

  String _formatAmount(double value, String currency) {
    return '${value.toStringAsFixed(2)} $currency';
  }

  void _toggleStatusFilter(String status) {
    setState(() {
      _statusFilter = _statusFilter == status ? null : status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final appSettings = ref.watch(appSettingsProvider);
    final currency = appSettings.currency;

    final invoices = ref
        .watch(invoicesProvider)
        .where(
          (invoice) => invoice.type == widget.type && invoice.isTemplate == false,
        )
        .toList();

    final clients = ref.watch(clientsProvider);
    final query = _searchController.text.trim().toLowerCase();
    final showStatusFilters = widget.type == 'invoice';

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
      final normalizedStatus = normalizeInvoiceStatus(invoice.status);

      final matchesQuery = query.isEmpty ||
          invoice.invoiceNumber.toLowerCase().contains(query) ||
          clientName.contains(query) ||
          normalizedStatus.contains(query);

      final matchesStatus = !showStatusFilters ||
          _statusFilter == null ||
          normalizedStatus == _statusFilter;

      return matchesQuery && matchesStatus;
    }).toList()
      ..sort((a, b) {
        final dateCompare = b.issueDate.compareTo(a.issueDate);
        if (dateCompare != 0) return dateCompare;
        return b.invoiceNumber.compareTo(a.invoiceNumber);
      });

    final latestDocument = invoices.isEmpty
        ? null
        : (List<InvoiceModel>.from(invoices)
              ..sort((a, b) {
                final dateCompare = b.issueDate.compareTo(a.issueDate);
                if (dateCompare != 0) return dateCompare;
                return b.invoiceNumber.compareTo(a.invoiceNumber);
              }))
            .first;

    final visibleTotal = filteredInvoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.total,
    );

    final statusChips = <_StatusFilterChipData>[
      _StatusFilterChipData(
        status: 'paid',
        label: t.statusPaid,
        color: _statusColor('paid'),
      ),
      _StatusFilterChipData(
        status: 'unpaid',
        label: t.statusUnpaid,
        color: _statusColor('unpaid'),
      ),
      _StatusFilterChipData(
        status: 'partial',
        label: t.statusPartial,
        color: _statusColor('partial'),
      ),
      _StatusFilterChipData(
        status: 'draft',
        label: t.statusDraft,
        color: _statusColor('draft'),
      ),
    ];

    final documentTitle =
        widget.type == 'quote' ? t.quotePreviewTitle : t.invoicesTitle;
    final createLabel = widget.type == 'quote' ? t.newQuote : t.newInvoice;
    final searchHint = t.searchInvoices;

    return Scaffold(
      appBar: AppBar(
        title: Text(documentTitle),
        actions: [
          IconButton(
            tooltip: t.templates,
            onPressed: _openTemplates,
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
                hintText: searchHint,
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
                        tooltip: t.cancel,
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (showStatusFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: statusChips
                      .map(
                        (chip) => FilterChip(
                          selected: _statusFilter == chip.status,
                          label: Text(chip.label),
                          selectedColor: chip.color.withValues(alpha: 0.16),
                          checkmarkColor: chip.color,
                          side: BorderSide(
                            color: _statusFilter == chip.status
                                ? chip.color
                                : Theme.of(context).dividerColor,
                          ),
                          labelStyle: TextStyle(
                            color: _statusFilter == chip.status ? chip.color : null,
                            fontWeight: _statusFilter == chip.status
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          onSelected: (_) => _toggleStatusFilter(chip.status),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _ListSummaryCard(
              title: documentTitle,
              countValue: filteredInvoices.length.toString(),
              amountLabel: t.total,
              amountValue: _formatAmount(visibleTotal, currency),
              actionLabel: createLabel,
              onActionPressed: _openCreateDocument,
              secondaryActionLabel: t.templates,
              onSecondaryActionPressed: _openTemplates,
            ),
          ),
          if (latestDocument != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _QuickReuseCard(
                title: latestDocument.invoiceNumber,
                subtitle: findClient(latestDocument.clientId)?.name ?? '',
                buttonLabel: t.duplicate,
                onPressed: () => _openDuplicateDocument(latestDocument),
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
                        subtitle: searchHint,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredInvoices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final invoice = filteredInvoices[index];
                          final client = findClient(invoice.clientId);
                          final dateText = DateFormat.yMMMd(
                            Localizations.localeOf(context).languageCode,
                          ).format(invoice.issueDate);

                          return _DocumentCard(
                            invoice: invoice,
                            client: client,
                            dateText: dateText,
                            currency: currency,
                            statusLabel: localizeInvoiceStatus(t, invoice.status),
                            statusColor: _statusColor(invoice.status),
                            totalLabel: t.total,
                            paidLabel: t.paidAmount,
                            remainingLabel: t.remainingAmount,
                            clientLabel: t.client,
                            dateLabel: t.date,
                            convertedLabel: t.quoteAlreadyConverted,
                            onMenuSelected: (value) => _handleMenuAction(
                              context: context,
                              t: t,
                              invoice: invoice,
                              action: value,
                            ),
                            showConvertAction:
                                widget.type == 'quote' && !invoice.isConvertedQuote,
                            convertLabel: t.convertToInvoice,
                            saveTemplateLabel: t.saveAsTemplate,
                            deleteLabel: t.delete,
                            onPreview: client == null
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => InvoicePreviewScreen(
                                          invoice: invoice,
                                          client: client,
                                        ),
                                      ),
                                    );
                                  },
                            onEdit: client == null
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CreateInvoiceScreen(
                                          type: widget.type,
                                          invoice: invoice,
                                        ),
                                      ),
                                    );
                                  },
                            onDuplicate: () => _openDuplicateDocument(invoice),
                            previewLabel: t.preview,
                            editLabel: t.edit,
                            duplicateLabel: t.duplicate,
                            actionConvert: _actionConvert,
                            actionSaveTemplate: _actionSaveTemplate,
                            actionDelete: _actionDelete,
                            formatAmount: _formatAmount,
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDocument,
        icon: const Icon(Icons.add),
        label: Text(createLabel),
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

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.invoice,
    required this.client,
    required this.dateText,
    required this.currency,
    required this.statusLabel,
    required this.statusColor,
    required this.totalLabel,
    required this.paidLabel,
    required this.remainingLabel,
    required this.clientLabel,
    required this.dateLabel,
    required this.convertedLabel,
    required this.onMenuSelected,
    required this.showConvertAction,
    required this.convertLabel,
    required this.saveTemplateLabel,
    required this.deleteLabel,
    required this.onPreview,
    required this.onEdit,
    required this.onDuplicate,
    required this.previewLabel,
    required this.editLabel,
    required this.duplicateLabel,
    required this.actionConvert,
    required this.actionSaveTemplate,
    required this.actionDelete,
    required this.formatAmount,
  });

  final InvoiceModel invoice;
  final ClientModel? client;
  final String dateText;
  final String currency;
  final String statusLabel;
  final Color statusColor;
  final String totalLabel;
  final String paidLabel;
  final String remainingLabel;
  final String clientLabel;
  final String dateLabel;
  final String convertedLabel;
  final ValueChanged<String> onMenuSelected;
  final bool showConvertAction;
  final String convertLabel;
  final String saveTemplateLabel;
  final String deleteLabel;
  final VoidCallback? onPreview;
  final VoidCallback? onEdit;
  final VoidCallback onDuplicate;
  final String previewLabel;
  final String editLabel;
  final String duplicateLabel;
  final String actionConvert;
  final String actionSaveTemplate;
  final String actionDelete;
  final String Function(double value, String currency) formatAmount;

  @override
  Widget build(BuildContext context) {
    final isInvoice = invoice.type == 'invoice';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaChip(
                            icon: Icons.calendar_today_outlined,
                            label: '$dateLabel: $dateText',
                          ),
                          if (client != null)
                            _MetaChip(
                              icon: Icons.person_outline,
                              label: '$clientLabel: ${client!.name}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusBadge(
                      label: statusLabel,
                      color: statusColor,
                    ),
                    PopupMenuButton<String>(
                      onSelected: onMenuSelected,
                      itemBuilder: (context) => [
                        if (showConvertAction)
                          PopupMenuItem(
                            value: actionConvert,
                            child: Text(convertLabel),
                          ),
                        PopupMenuItem(
                          value: actionSaveTemplate,
                          child: Text(saveTemplateLabel),
                        ),
                        PopupMenuItem(
                          value: actionDelete,
                          child: Text(deleteLabel),
                        ),
                      ],
                    ),
                  ],
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
              child: isInvoice
                  ? Row(
                      children: [
                        Expanded(
                          child: _AmountTile(
                            label: totalLabel,
                            value: formatAmount(invoice.total, currency),
                            emphasize: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AmountTile(
                            label: paidLabel,
                            value: formatAmount(invoice.paidAmount, currency),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AmountTile(
                            label: remainingLabel,
                            value: formatAmount(invoice.remainingAmount, currency),
                            emphasize: invoice.remainingAmount > 0,
                          ),
                        ),
                      ],
                    )
                  : _AmountTile(
                      label: totalLabel,
                      value: formatAmount(invoice.total, currency),
                      emphasize: true,
                    ),
            ),
            if (invoice.type == 'quote' && invoice.isConvertedQuote) ...[
              const SizedBox(height: 10),
              Text(
                convertedLabel,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(previewLabel),
                ),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(editLabel),
                ),
                OutlinedButton.icon(
                  onPressed: onDuplicate,
                  icon: const Icon(Icons.copy_outlined),
                  label: Text(duplicateLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSummaryCard extends StatelessWidget {
  const _ListSummaryCard({
    required this.title,
    required this.countValue,
    required this.amountLabel,
    required this.amountValue,
    required this.actionLabel,
    required this.onActionPressed,
    this.secondaryActionLabel,
    this.onSecondaryActionPressed,
  });

  final String title;
  final String countValue;
  final String amountLabel;
  final String amountValue;
  final String actionLabel;
  final VoidCallback onActionPressed;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _SummaryItem(
                        label: title,
                        value: countValue,
                      ),
                      _SummaryItem(
                        label: amountLabel,
                        value: amountValue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: onActionPressed,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel),
                ),
                if (secondaryActionLabel != null &&
                    onSecondaryActionPressed != null)
                  OutlinedButton.icon(
                    onPressed: onSecondaryActionPressed,
                    icon: const Icon(Icons.bookmarks_outlined),
                    label: Text(secondaryActionLabel!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReuseCard extends StatelessWidget {
  const _QuickReuseCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        leading: const Icon(Icons.history),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.copy_outlined),
          label: Text(buttonLabel),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
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

class _StatusFilterChipData {
  const _StatusFilterChipData({
    required this.status,
    required this.label,
    required this.color,
  });

  final String status;
  final String label;
  final Color color;
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