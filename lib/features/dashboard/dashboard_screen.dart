import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/invoices_provider.dart';
import '../../utils/invoice_status_localizer.dart';
import '../clients/clients_screen.dart';
import '../invoices/invoices_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final allDocuments = ref.watch(invoicesProvider);
    final clients = ref.watch(clientsProvider);
    final appSettings = ref.watch(appSettingsProvider);
    final currency = appSettings.currency;

    final invoices =
        allDocuments.where((invoice) => invoice.type == 'invoice').toList();
    final quotes =
        allDocuments.where((invoice) => invoice.type == 'quote').toList();

    final totalInvoices = invoices.length;
    final totalQuotes = quotes.length;

    final paidInvoices = invoices
        .where((invoice) => normalizeInvoiceStatus(invoice.status) == 'paid')
        .toList();

    final unpaidInvoices = invoices
        .where((invoice) => normalizeInvoiceStatus(invoice.status) == 'unpaid')
        .toList();

    final partialInvoices = invoices
        .where((invoice) => normalizeInvoiceStatus(invoice.status) == 'partial')
        .toList();

    final draftInvoices = invoices
        .where((invoice) => normalizeInvoiceStatus(invoice.status) == 'draft')
        .toList();

    final totalRevenue = invoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.total,
    );

    final collectedAmount = invoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.paidAmount,
    );

    final outstandingBalance = invoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.remainingAmount,
    );

    final collectedRatio = totalRevenue <= 0
        ? 0.0
        : (collectedAmount / totalRevenue).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            t.welcome,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            t.dashboard,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.45,
            children: [
              _SummaryCard(
                title: t.totalRevenue,
                value: '${totalRevenue.toStringAsFixed(2)} $currency',
                icon: Icons.receipt_long,
                emphasize: true,
              ),
              _SummaryCard(
                title: t.collectedAmount,
                value: '${collectedAmount.toStringAsFixed(2)} $currency',
                icon: Icons.payments_outlined,
              ),
              _SummaryCard(
                title: t.outstandingBalance,
                value: '${outstandingBalance.toStringAsFixed(2)} $currency',
                icon: Icons.account_balance_wallet_outlined,
                emphasize: outstandingBalance > 0,
              ),
              _SummaryCard(
                title: t.totalClients,
                value: clients.length.toString(),
                icon: Icons.people_outline,
              ),
              _SummaryCard(
                title: t.totalInvoices,
                value: totalInvoices.toString(),
                icon: Icons.description_outlined,
              ),
              _SummaryCard(
                title: t.totalQuotes,
                value: totalQuotes.toString(),
                icon: Icons.request_quote_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _CashFlowCard(
            collectedLabel: t.collectedAmount,
            pendingLabel: t.pendingAmount,
            collectedValue: '${collectedAmount.toStringAsFixed(2)} $currency',
            pendingValue: '${outstandingBalance.toStringAsFixed(2)} $currency',
            progress: collectedRatio,
          ),
          const SizedBox(height: 18),
          Text(
            t.invoiceStatusBreakdown,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.55,
            children: [
              _StatusCard(
                title: t.statusPaid,
                value: paidInvoices.length.toString(),
                icon: Icons.check_circle_outline,
              ),
              _StatusCard(
                title: t.statusUnpaid,
                value: unpaidInvoices.length.toString(),
                icon: Icons.error_outline,
              ),
              _StatusCard(
                title: t.statusPartial,
                value: partialInvoices.length.toString(),
                icon: Icons.timelapse_outlined,
              ),
              _StatusCard(
                title: t.statusDraft,
                value: draftInvoices.length.toString(),
                icon: Icons.edit_note_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _WideSummaryCard(
            title: t.pendingAmount,
            value: '${outstandingBalance.toStringAsFixed(2)} $currency',
            icon: Icons.trending_down_outlined,
          ),
          const SizedBox(height: 18),
          Text(
            t.quickActions,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: [
              _DashboardCard(
                icon: Icons.receipt_long,
                title: t.newInvoice,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InvoicesScreen(type: 'invoice'),
                    ),
                  );
                },
              ),
              _DashboardCard(
                icon: Icons.description,
                title: t.newQuote,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InvoicesScreen(type: 'quote'),
                    ),
                  );
                },
              ),
              _DashboardCard(
                icon: Icons.people,
                title: t.clients,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ClientsScreen(),
                    ),
                  );
                },
              ),
              _DashboardCard(
                icon: Icons.history,
                title: t.history,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InvoicesScreen(type: 'invoice'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CashFlowCard extends StatelessWidget {
  const _CashFlowCard({
    required this.collectedLabel,
    required this.pendingLabel,
    required this.collectedValue,
    required this.pendingValue,
    required this.progress,
  });

  final String collectedLabel;
  final String pendingLabel;
  final String collectedValue;
  final String pendingValue;
  final double progress;

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
                  child: _FlowMetric(
                    label: collectedLabel,
                    value: collectedValue,
                    icon: Icons.south_west,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FlowMetric(
                    label: pendingLabel,
                    value: pendingValue,
                    icon: Icons.north_east,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowMetric extends StatelessWidget {
  const _FlowMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
    required this.icon,
    this.emphasize = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22),
            const Spacer(),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: emphasize ? colorScheme.primary : null,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _WideSummaryCard extends StatelessWidget {
  const _WideSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        leading: Icon(icon, size: 22),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}