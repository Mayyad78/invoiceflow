import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/invoice_item_model.dart';

class AddItemDialogResult {
  final InvoiceItemModel item;
  final String? catalogItemId;

  const AddItemDialogResult({
    required this.item,
    required this.catalogItemId,
  });
}

Future<AddItemDialogResult?> showAddItemDialog(
  BuildContext context, {
  InvoiceItemModel? item,
  required List<CatalogItemModel> catalogItems,
  String? selectedCatalogItemId,
}) async {
  final t = AppLocalizations.of(context)!;
  final descriptionController =
      TextEditingController(text: item?.description ?? '');
  final quantityController =
      TextEditingController(text: (item?.quantity ?? 1).toString());
  final unitPriceController = TextEditingController(
    text: (item?.unitPrice ?? 0).toString(),
  );

  final isEdit = item != null;

  return showDialog<AddItemDialogResult>(
    context: context,
    builder: (dialogContext) {
      String? currentCatalogItemId = selectedCatalogItemId;

      CatalogItemModel? findCatalogItemById(String? id) {
        if (id == null) {
          return null;
        }

        for (final catalogItem in catalogItems) {
          if (catalogItem.id == id) {
            return catalogItem;
          }
        }

        return null;
      }

      List<CatalogItemModel> buildSuggestions(String rawQuery) {
        final query = rawQuery.trim().toLowerCase();
        if (query.isEmpty) {
          return [];
        }

        final startsWithMatches = <CatalogItemModel>[];
        final containsMatches = <CatalogItemModel>[];

        for (final catalogItem in catalogItems) {
          final description = catalogItem.description.trim();
          if (description.isEmpty) {
            continue;
          }

          final normalizedDescription = description.toLowerCase();
          if (normalizedDescription.startsWith(query)) {
            startsWithMatches.add(catalogItem);
          } else if (normalizedDescription.contains(query)) {
            containsMatches.add(catalogItem);
          }
        }

        return [...startsWithMatches, ...containsMatches].take(5).toList();
      }

      void applyCatalogItem(
        CatalogItemModel catalogItem,
        void Function(void Function()) setDialogState,
      ) {
        currentCatalogItemId = catalogItem.id;
        descriptionController.text = catalogItem.description;
        quantityController.text = catalogItem.quantity.toString();
        unitPriceController.text = catalogItem.unitPrice.toString();

        descriptionController.selection = TextSelection.fromPosition(
          TextPosition(offset: descriptionController.text.length),
        );

        setDialogState(() {});
      }

      return StatefulBuilder(
        builder: (context, setDialogState) {
          final activeCatalogItem = findCatalogItemById(currentCatalogItemId);
          if (activeCatalogItem != null &&
              descriptionController.text.trim() !=
                  activeCatalogItem.description.trim()) {
            currentCatalogItemId = null;
          }

          final suggestions = buildSuggestions(descriptionController.text);
          final showSuggestions = suggestions.isNotEmpty;

          return AlertDialog(
            title: Text(isEdit ? '${t.edit} ${t.addItem}' : t.addItem),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: t.description),
                      autofocus: true,
                      onChanged: (_) {
                        setDialogState(() {});
                      },
                    ),
                    if (showSuggestions) ...[
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < suggestions.length; i++) ...[
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => applyCatalogItem(
                                    suggestions[i],
                                    setDialogState,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          suggestions[i].description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${t.quantity}: ${suggestions[i].quantity} • ${t.unitPrice}: ${suggestions[i].unitPrice}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (i != suggestions.length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: t.quantity),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: unitPriceController,
                      decoration: InputDecoration(labelText: t.unitPrice),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(t.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final description = descriptionController.text.trim();
                  final quantity =
                      int.tryParse(quantityController.text.trim()) ?? 1;
                  final unitPrice =
                      double.tryParse(unitPriceController.text.trim()) ?? 0;

                  if (description.isEmpty) {
                    return;
                  }

                  Navigator.of(dialogContext).pop(
                    AddItemDialogResult(
                      item: InvoiceItemModel(
                        description: description,
                        quantity: quantity,
                        unitPrice: unitPrice,
                      ),
                      catalogItemId: currentCatalogItemId,
                    ),
                  );
                },
                child: Text(isEdit ? t.saveChanges : t.addItem),
              ),
            ],
          );
        },
      );
    },
  );
}
