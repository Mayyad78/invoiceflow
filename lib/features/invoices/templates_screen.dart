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

  Future<String?> _promptTemplateName(
    BuildContext context,
    AppLocalizations t, {
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
              title: Text(t.renameTemplate),
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

  Future<bool?> _confirmDeleteTemplate(
    BuildContext context,
    AppLocalizations t,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.confirmDelete),
        content: Text(t.deleteTemplateMessage),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final clients = ref.watch(clientsProvider);
    final templates = ref
        .watch(invoicesProvider)
        .where((invoice) => invoice.type == type && invoice.isTemplate)
        .toList()
      ..sort((a, b) {
        final nameA = (a.templateName ?? '').toLowerCase();
        final nameB = (b.templateName ?? '').toLowerCase();
        final nameCompare = nameA.compareTo(nameB);
        if (nameCompare != 0) return nameCompare;
        return b.issueDate.compareTo(a.issueDate);
      });

    ClientModel? findClient(String clientId) {
      try {
        return clients.firstWhere((client) => client.id == clientId);
      } catch (_) {
        return null;
      }
    }

    Future<void> useTemplate(InvoiceModel template) async {
      final originalDuration = template.dueDate.difference(template.issueDate);

      final reusableDocument = template.copyWith(
        id: const Uuid().v4(),
        invoiceNumber: '',
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(
          originalDuration.isNegative ? Duration.zero : originalDuration,
        ),
        items: template.items
            .map(
              (item) => InvoiceItemModel(
                description: item.description,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
              ),
            )
            .toList(),
        status: 'draft',
        paidAmount: 0,
        isTemplate: false,
        clearConvertedInvoiceId: true,
        clearTemplateName: true,
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

    Future<void> renameTemplate(InvoiceModel template) async {
      final newName = await _promptTemplateName(
        context,
        t,
        initialValue: template.templateName,
      );

      if (!context.mounted) return;

      if (newName == null || newName.trim().isEmpty) {
        return;
      }

      await ref.read(invoicesProvider.notifier).updateInvoice(
            template.copyWith(templateName: newName),
          );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.templateUpdated)),
      );
    }

    Future<void> deleteTemplate(String id) async {
      final confirmed = await _confirmDeleteTemplate(context, t);
      if (confirmed != true) return;

      await ref.read(invoicesProvider.notifier).deleteInvoice(id);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          type == 'quote' ? t.quoteTemplates : t.invoiceTemplates,
        ),
      ),
      body: templates.isEmpty
          ? _TemplateEmptyState(
              title: t.noTemplatesYet,
              subtitle: type == 'quote'
                  ? t.startByCreatingQuoteTemplate
                  : t.startByCreatingInvoiceTemplate,
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
                            (template.templateName != null &&
                                    template.templateName!.trim().isNotEmpty)
                                ? template.templateName!
                                : t.template,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              if (client != null)
                                Text('${t.client}: ${client.name}'),
                              const SizedBox(height: 4),
                              Text('${t.date}: $dateText'),
                              const SizedBox(height: 4),
                              Text('${t.items}: ${template.items.length}'),
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
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CreateInvoiceScreen(
                                          type: template.type,
                                          invoice: template,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  label: Text(t.editTemplate),
                                ),
                                TextButton.icon(
                                  onPressed: () => renameTemplate(template),
                                  icon:
                                      const Icon(Icons.drive_file_rename_outline),
                                  label: Text(t.renameTemplate),
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

class _TemplateEmptyState extends StatelessWidget {
  const _TemplateEmptyState({
    required this.title,
    required this.subtitle,
  });

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
            const Icon(Icons.bookmarks_outlined, size: 56),
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