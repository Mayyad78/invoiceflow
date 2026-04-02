import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/invoice_item_model.dart';

class AddItemDialogResult {
  const AddItemDialogResult({
    required this.item,
    this.catalogItemId,
  });

  final InvoiceItemModel item;
  final String? catalogItemId;
}

Future<AddItemDialogResult?> showAddItemDialog(
  BuildContext context, {
  InvoiceItemModel? item,
  required List<CatalogItemModel> catalogItems,
  String? selectedCatalogItemId,
  Map<String, InvoiceItemModel>? rememberedCatalogDefaults,
}) async {
  final t = AppLocalizations.of(context)!;
  final descriptionController =
      TextEditingController(text: item?.description ?? '');
  final quantityController =
      TextEditingController(text: (item?.quantity ?? 1).toString());
  final unitPriceController = TextEditingController(
    text: (item?.unitPrice ?? 0).toString(),
  );

  String? activeCatalogItemId = selectedCatalogItemId;
  final isEdit = item != null;

  return showDialog<AddItemDialogResult>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final query = descriptionController.text.trim().toLowerCase();
          final suggestions = query.isEmpty
              ? <CatalogItemModel>[]
              : catalogItems
                    .where(
                      (catalogItem) => catalogItem.description
                          .trim()
                          .toLowerCase()
                          .contains(query),
                    )
                    .take(5)
                    .toList();

          void applyCatalogItem(CatalogItemModel catalogItem) {
            final rememberedItem = rememberedCatalogDefaults?[catalogItem.id];
            final quantity = rememberedItem?.quantity ?? catalogItem.quantity;
            final unitPrice = rememberedItem?.unitPrice ?? catalogItem.unitPrice;

            descriptionController.text = catalogItem.description;
            quantityController.text = quantity.toString();
            unitPriceController.text = unitPrice.toString();
            activeCatalogItemId = catalogItem.id;
            setDialogState(() {});
          }

          return AlertDialog(
            title: Text(isEdit ? '${t.edit} ${t.addItem}' : t.addItem),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: t.description,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        activeCatalogItemId = null;
                        setDialogState(() {});
                      },
                    ),
                    if (suggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: suggestions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final suggestion = entry.value;
                            final rememberedItem =
                                rememberedCatalogDefaults?[suggestion.id];
                            final subtitleQuantity =
                                rememberedItem?.quantity ?? suggestion.quantity;
                            final subtitlePrice =
                                rememberedItem?.unitPrice ?? suggestion.unitPrice;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  dense: true,
                                  title: Text(
                                    suggestion.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${t.quantity}: $subtitleQuantity • ${t.unitPrice}: ${subtitlePrice.toStringAsFixed(2)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => applyCatalogItem(suggestion),
                                ),
                                if (index != suggestions.length - 1)
                                  const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: t.quantity,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: unitPriceController,
                      decoration: InputDecoration(
                        labelText: t.unitPrice,
                        border: const OutlineInputBorder(),
                      ),
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
                      catalogItemId: activeCatalogItemId,
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
