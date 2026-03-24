import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/invoice_item_model.dart';

Future<InvoiceItemModel?> showAddItemDialog(
  BuildContext context, {
  InvoiceItemModel? item,
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

  return showDialog<InvoiceItemModel>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(isEdit ? '${t.edit} ${t.addItem}' : t.addItem),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: t.description),
              ),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final description = descriptionController.text.trim();
              final quantity = int.tryParse(quantityController.text.trim()) ?? 1;
              final unitPrice =
                  double.tryParse(unitPriceController.text.trim()) ?? 0;

              if (description.isEmpty) {
                return;
              }

              Navigator.of(dialogContext).pop(
                InvoiceItemModel(
                  description: description,
                  quantity: quantity,
                  unitPrice: unitPrice,
                ),
              );
            },
            child: Text(isEdit ? t.saveChanges : t.save),
          ),
        ],
      );
    },
  );
}