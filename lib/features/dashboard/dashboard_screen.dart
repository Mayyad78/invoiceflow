import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/invoices_provider.dart';
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

    final invoices = allDocuments.where((invoice) => invoice.type == 'invoice').toList();
    final quotes = allDocuments.where((invoice) => invoice.type == 'quote').toList();

    final totalInvoices = invoices.length;
    final totalQuotes = quotes.length;

    final paidInvoices = invoices.where((invoice) => invoice.status == 'paid').toList();
    final unpaidInvoices = invoices.where((invoice) => invoice.status == 'unpaid').toList();
    final partialInvoices = invoices.where((invoice) {
      return invoice.status == 'partial' || invoice.status == 'partially_paid';
    }).toList();
    final draftInvoices = invoices.where((invoice) => invoice.status == 'draft').toList();

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
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.welcome,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Text(
            t.dashboard,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              _SummaryCard(
                title: t.totalRevenue,
                value: '${totalRevenue.toStringAsFixed(2)} $currency',
                icon: Icons.receipt_long,
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
          const SizedBox(height: 24),
          Text(
            t.invoiceStatusBreakdown,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
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
          const SizedBox(height: 24),
          _WideSummaryCard(
            title: t.pendingAmount,
            value: '${outstandingBalance.toStringAsFixed(2)} $currency',
            icon: Icons.trending_down_outlined,
          ),
          const SizedBox(height: 24),
          Text(
            t.quickActions,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(title),
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(title),
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
        leading: Icon(icon, size: 28),
        title: Text(title),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}