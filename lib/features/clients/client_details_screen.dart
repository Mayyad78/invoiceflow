import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoices_provider.dart';
import '../invoices/invoice_preview_screen.dart';

class ClientDetailsScreen extends ConsumerWidget {
  const ClientDetailsScreen({
    super.key,
    required this.client,
  });

  final ClientModel client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final documents = ref
        .watch(invoicesProvider)
        .where((invoice) => invoice.clientId == client.id)
        .toList()
      ..sort((a, b) {
        final dateCompare = b.issueDate.compareTo(a.issueDate);
        if (dateCompare != 0) return dateCompare;
        return b.invoiceNumber.compareTo(a.invoiceNumber);
      });

    final totalBilled = documents.fold<double>(
      0,
      (sum, invoice) => sum + invoice.total,
    );

    final totalPaid = documents.fold<double>(
      0,
      (sum, invoice) => sum + invoice.paidAmount,
    );

    final totalRemaining = documents.fold<double>(
      0,
      (sum, invoice) => sum + invoice.remainingAmount,
    );

    final invoicesCount =
        documents.where((invoice) => invoice.type == 'invoice').length;
    final quotesCount =
        documents.where((invoice) => invoice.type == 'quote').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.clientDetails),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (client.email.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('${t.email}: ${client.email}'),
                  ],
                  if (client.phone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('${t.phone}: ${client.phone}'),
                  ],
                  if (client.address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('${t.address}: ${client.address}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.clientSummary,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryCard(
                title: t.totalDocuments,
                value: documents.length.toString(),
              ),
              _SummaryCard(
                title: t.totalInvoices,
                value: invoicesCount.toString(),
              ),
              _SummaryCard(
                title: t.totalQuotes,
                value: quotesCount.toString(),
              ),
              _SummaryCard(
                title: t.totalRevenue,
                value: totalBilled.toStringAsFixed(2),
              ),
              _SummaryCard(
                title: t.paidAmount,
                value: totalPaid.toStringAsFixed(2),
              ),
              _SummaryCard(
                title: t.remainingAmount,
                value: totalRemaining.toStringAsFixed(2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            t.clientHistory,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (documents.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      t.noClientDocuments,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...documents.map(
              (invoice) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DocumentCard(
                  invoice: invoice,
                  client: client,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.invoice,
    required this.client,
  });

  final InvoiceModel invoice;
  final ClientModel client;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final dateText = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    ).format(invoice.issueDate);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(invoice.invoiceNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              invoice.type == 'quote'
                  ? t.invoiceTypeQuote
                  : t.invoiceTypeInvoice,
            ),
            const SizedBox(height: 4),
            Text('${t.date}: $dateText'),
            const SizedBox(height: 4),
            Text('${t.total}: ${invoice.total.toStringAsFixed(2)}'),
            if (invoice.type == 'invoice') ...[
              const SizedBox(height: 4),
              Text('${t.paidAmount}: ${invoice.paidAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              Text(
                '${t.remainingAmount}: ${invoice.remainingAmount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 4),
              Text('${t.status}: ${_localizedStatus(t, invoice.status)}'),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.visibility_outlined),
          tooltip: t.preview,
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
      case 'partially_paid':
        return t.statusPartial;
      default:
        return t.statusDraft;
    }
  }
}