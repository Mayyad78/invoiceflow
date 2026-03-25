import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client_model.dart';
import '../../models/invoice_item_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/clients_provider.dart';
import '../../providers/invoices_provider.dart';
import 'create_invoice_screen.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({
    super.key,
    required this.type,
  });

  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final clients = ref.watch(clientsProvider);
    final templates = ref
        .watch(invoicesProvider)
        .where((invoice) => invoice.type == type && invoice.isTemplate)
        .toList()
      ..sort((a, b) {
        final dateCompare = b.issueDate.compareTo(a.issueDate);
        if (dateCompare != 0) return dateCompare;
        return a.notes.compareTo(b.notes);
      });

    ClientModel? findClient(String clientId) {
      try {
        return clients.firstWhere((client) => client.id == clientId);
      } catch (_) {
        return null;
      }
    }

    Future<void> useTemplate(InvoiceModel template) async {
      final clonedItems = template.items
          .map(
            (item) => InvoiceItemModel(
              description: item.description,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          )
          .toList();

      final reusableDocument = template.copyWith(
        id: const Uuid().v4(),
        invoiceNumber: '',
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(
          template.dueDate.difference(template.issueDate).isNegative
              ? Duration.zero
              : template.dueDate.difference(template.issueDate),
        ),
        items: clonedItems,
        status: 'draft',
        paidAmount: 0,
        isTemplate: false,
        clearConvertedInvoiceId: true,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateInvoiceScreen(
            type: reusableDocument.type,
            invoice: reusableDocument,
            isDuplicate: true,
          ),
        ),
      );
    }

    Future<void> deleteTemplate(String id) async {
      await ref.read(invoicesProvider.notifier).deleteInvoice(id);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          type == 'quote' ? t.quoteTemplates : t.invoiceTemplates,
        ),
      ),
      body: templates.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t.noTemplatesYet,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final template = templates[index];
                final client = findClient(template.clientId);
                final dateText = DateFormat.yMMMd(
                  Localizations.localeOf(context).languageCode,
                ).format(template.issueDate);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            template.notes.trim().isNotEmpty
                                ? template.notes
                                : t.template,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              if (client != null) Text('${t.client}: ${client.name}'),
                              const SizedBox(height: 4),
                              Text('${t.date}: $dateText'),
                              const SizedBox(height: 4),
                              Text(
                                '${t.items}: ${template.items.length}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${t.total}: ${template.total.toStringAsFixed(2)}',
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
                                TextButton.icon(
                                  onPressed: () => useTemplate(template),
                                  icon: const Icon(Icons.play_arrow_outlined),
                                  label: Text(t.useTemplate),
                                ),
                                TextButton.icon(
                                  onPressed: () => deleteTemplate(template.id),
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
    );
  }
}