import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/invoice_item_model.dart';

Future<InvoiceItemModel?> showAddItemDialog(BuildContext context) async {
  final t = AppLocalizations.of(context)!;

  final descriptionController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final unitPriceController = TextEditingController(text: '0');

  return showDialog<InvoiceItemModel>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(t.addItem),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
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

              Navigator.of(context).pop(
                InvoiceItemModel(
                  description: description,
                  quantity: quantity,
                  unitPrice: unitPrice,
                ),
              );
            },
            child: Text(t.save),
          ),
        ],
      );
    },
  );
}