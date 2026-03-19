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
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 'quote' ? t.newQuote : t.invoicesTitle),
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
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: invoices.isEmpty
                ? Center(child: Text(t.noInvoicesYet))
                : filteredInvoices.isEmpty
                    ? Center(child: Text(t.noResultsFound))
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
                                        const SizedBox(height: 4),
                                        Text(
                                          '${t.status}: ${_localizedStatus(t, invoice.status)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _statusColor(invoice.status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      DropdownButton<String>(
                                        value: invoice.status,
                                        items: [
                                          DropdownMenuItem(
                                            value: 'draft',
                                            child: Text(t.statusDraft),
                                          ),
                                          DropdownMenuItem(
                                            value: 'paid',
                                            child: Text(t.statusPaid),
                                          ),
                                          DropdownMenuItem(
                                            value: 'unpaid',
                                            child: Text(t.statusUnpaid),
                                          ),
                                        ],
                                        onChanged: (value) async {
                                          if (value == null) return;

                                          await ref
                                              .read(invoicesProvider.notifier)
                                              .updateStatus(invoice.id, value);
                                        },
                                      ),
                                      Row(
                                        children: [
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
                                              await ref
                                                  .read(
                                                    invoicesProvider.notifier,
                                                  )
                                                  .deleteInvoice(invoice.id);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateInvoiceScreen(type: widget.type),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  static String _localizedStatus(AppLocalizations t, String status) {
    switch (status) {
      case 'paid':
        return t.statusPaid;
      case 'unpaid':
        return t.statusUnpaid;
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
      default:
        return Colors.orange;
    }
  }
}