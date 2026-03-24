import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client_model.dart';
import '../../providers/clients_provider.dart';
import '../../providers/invoices_provider.dart';
import 'create_invoice_screen.dart';
import 'invoice_preview_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final invoices = ref
        .watch(invoicesProvider)
        .where((invoice) => invoice.type == widget.type)
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
          invoice.status.toLowerCase().contains(query);
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
                                        const SizedBox(height: 6),
                                        _StatusBadge(
                                          label: _localizedStatus(t, invoice.status),
                                          color: _statusColor(invoice.status),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    children: [
                                      Wrap(
                                        spacing: 4,
                                        children: [
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
                                            icon: const Icon(Icons.edit_outlined),
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
                                            icon: const Icon(Icons.visibility_outlined),
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
                                                    .read(invoicesProvider.notifier)
                                                    .deleteInvoice(invoice.id);
                                              }
                                            },
                                            icon: const Icon(Icons.delete_outline),
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

  static String _localizedStatus(AppLocalizations t, String status) {
    switch (status) {
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

  static Color _statusColor(String status) {
    switch (status) {
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