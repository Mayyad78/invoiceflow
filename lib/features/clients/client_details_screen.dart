import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/invoices_provider.dart';
import '../invoices/create_invoice_screen.dart';
import '../invoices/invoice_preview_screen.dart';
import 'add_client_screen.dart';

class ClientDetailsScreen extends ConsumerWidget {
  const ClientDetailsScreen({
    super.key,
    required this.client,
  });

  final ClientModel client;

  String _formatAmount(double value, String currency) {
    return '${value.toStringAsFixed(2)} $currency';
  }

  InvoiceModel _buildPrefilledInvoiceDraft() {
    final now = DateTime.now();

    return InvoiceModel(
      id: const Uuid().v4(),
      invoiceNumber: '',
      clientId: client.id,
      issueDate: now,
      dueDate: now.add(const Duration(days: 7)),
      items: const [],
      taxPercent: 0,
      discount: 0,
      notes: '',
      status: 'draft',
      type: 'invoice',
      paidAmount: 0,
      convertedInvoiceId: null,
      isTemplate: false,
      templateName: null,
      isFavoriteTemplate: false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final currency = ref.watch(appSettingsProvider).currency;

    final clientInvoices = ref
        .watch(invoicesProvider)
        .where((invoice) => invoice.clientId == client.id && !invoice.isTemplate)
        .toList()
      ..sort((a, b) => b.issueDate.compareTo(a.issueDate));

    final totalDocuments = clientInvoices.length;
    final totalAmount = clientInvoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.total,
    );
    final totalPaid = clientInvoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.paidAmount,
    );
    final totalRemaining = clientInvoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.remainingAmount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        actions: [
          IconButton(
            tooltip: t.edit,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddClientScreen(client: client),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (client.email.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(client.email),
                  ],
                  if (client.phone.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(client.phone),
                  ],
                  if (client.address.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(client.address),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 18,
                runSpacing: 10,
                children: [
                  _SummaryTile(
                    label: t.totalInvoices,
                    value: totalDocuments.toString(),
                  ),
                  _SummaryTile(
                    label: t.total,
                    value: _formatAmount(totalAmount, currency),
                  ),
                  _SummaryTile(
                    label: t.paidAmount,
                    value: _formatAmount(totalPaid, currency),
                  ),
                  _SummaryTile(
                    label: t.remainingAmount,
                    value: _formatAmount(totalRemaining, currency),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.history,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateInvoiceScreen(
                        type: 'invoice',
                        invoice: _buildPrefilledInvoiceDraft(),
                        isDuplicate: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(t.newInvoice),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (clientInvoices.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      t.noInvoicesYet,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...clientInvoices.map(
              (invoice) {
                final issueDate = DateFormat.yMMMd(
                  Localizations.localeOf(context).languageCode,
                ).format(invoice.issueDate);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  invoice.invoiceNumber,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              Text(issueDate),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _SummaryTile(
                                label: t.total,
                                value: _formatAmount(invoice.total, currency),
                              ),
                              _SummaryTile(
                                label: t.paidAmount,
                                value: _formatAmount(invoice.paidAmount, currency),
                              ),
                              _SummaryTile(
                                label: t.remainingAmount,
                                value: _formatAmount(
                                  invoice.remainingAmount,
                                  currency,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => InvoicePreviewScreen(
                                        invoice: invoice,
                                        client: client,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.visibility_outlined),
                                label: Text(t.preview),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CreateInvoiceScreen(
                                        type: invoice.type,
                                        invoice: invoice,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                                label: Text(t.edit),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 3),
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