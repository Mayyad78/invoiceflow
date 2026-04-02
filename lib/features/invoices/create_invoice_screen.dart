import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/catalog_item_model.dart';
import '../../models/client_model.dart';
import '../../models/invoice_item_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/catalog_items_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/invoices_provider.dart';
import 'invoice_preview_screen.dart';
import 'widgets/add_item_dialog.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({
    super.key,
    this.type = 'invoice',
    this.invoice,
    this.isDuplicate = false,
  });

  final String type;
  final InvoiceModel? invoice;
  final bool isDuplicate;

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _taxController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  final _paidAmountController = TextEditingController(text: '0');

  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  ClientModel? _selectedClient;
  final List<InvoiceItemModel> _items = [];
  final List<String?> _itemCatalogIds = [];
  late String _initialGeneratedNumber;
  String _status = 'draft';

  bool get _isEdit => widget.invoice != null && !widget.isDuplicate;
  bool get _isDuplicate => widget.invoice != null && widget.isDuplicate;
  bool get _hasSourceInvoice => widget.invoice != null;
  bool get _isInvoice => widget.type == 'invoice';
  bool get _isTemplateEdit =>
      _isEdit && (widget.invoice?.isTemplate ?? false) == true;
  bool get _showPaymentSection => _isInvoice && !_isTemplateEdit;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      final invoice = widget.invoice!;
      _invoiceNumberController.text = invoice.invoiceNumber;
      _taxController.text = invoice.taxPercent.toString();
      _discountController.text = invoice.discount.toString();
      _notesController.text = invoice.notes;
      _paidAmountController.text = invoice.paidAmount.toStringAsFixed(2);
      _issueDate = invoice.issueDate;
      _dueDate = invoice.dueDate;
      _items.addAll(invoice.items.cast<InvoiceItemModel>());
      _itemCatalogIds.addAll(List<String?>.filled(invoice.items.length, null));
      _initialGeneratedNumber = invoice.invoiceNumber;
      _status = invoice.status;
    } else if (_isDuplicate) {
      final invoice = widget.invoice!;
      final settingsNotifier = ref.read(appSettingsProvider.notifier);
      final dueDuration = invoice.dueDate.difference(invoice.issueDate);

      _initialGeneratedNumber =
          settingsNotifier.previewDocumentNumber(widget.type);
      _invoiceNumberController.text = _initialGeneratedNumber;
      _taxController.text = invoice.taxPercent.toString();
      _discountController.text = invoice.discount.toString();
      _notesController.text = invoice.notes;
      _paidAmountController.text = '0';
      _issueDate = DateTime.now();
      _dueDate = _issueDate.add(
        dueDuration.isNegative ? Duration.zero : dueDuration,
      );
      _items.addAll(
        invoice.items.map(
          (item) => InvoiceItemModel(
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          ),
        ),
      );
      _itemCatalogIds.addAll(List<String?>.filled(invoice.items.length, null));
      _status = 'draft';
    } else {
      final settingsNotifier = ref.read(appSettingsProvider.notifier);
      _initialGeneratedNumber =
          settingsNotifier.previewDocumentNumber(widget.type);
      _invoiceNumberController.text = _initialGeneratedNumber;
      _status = 'draft';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_selectedClient != null || !_hasSourceInvoice) return;

    final clients = ref.read(clientsProvider);

    try {
      _selectedClient = clients.firstWhere(
        (client) => client.id == widget.invoice!.clientId,
      );
    } catch (_) {
      _selectedClient = null;
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  double get _taxAmount =>
      _subtotal * ((double.tryParse(_taxController.text) ?? 0) / 100);

  double get _discount => double.tryParse(_discountController.text) ?? 0;

  double get _total => _subtotal + _taxAmount - _discount;

  double get _paidAmount =>
      double.tryParse(_paidAmountController.text.trim()) ?? 0;

  double get _remainingAmount {
    final remaining = _total - _paidAmount;
    return remaining < 0 ? 0 : remaining;
  }

  String _normalizeDescription(String value) {
    return value.trim().toLowerCase();
  }

  int? _findExistingInvoiceItemIndex({
    required InvoiceItemModel item,
    String? catalogItemId,
  }) {
    for (var i = 0; i < _items.length; i++) {
      final currentItem = _items[i];
      final sameDescription = _normalizeDescription(currentItem.description) ==
          _normalizeDescription(item.description);
      final samePrice = currentItem.unitPrice == item.unitPrice;

      if (!sameDescription || !samePrice) {
        continue;
      }

      if (catalogItemId != null) {
        if (_itemCatalogIds[i] == catalogItemId) {
          return i;
        }
        continue;
      }

      return i;
    }

    return null;
  }

  void _addOrMergeInvoiceItem({
    required InvoiceItemModel item,
    String? catalogItemId,
  }) {
    final existingIndex = _findExistingInvoiceItemIndex(
      item: item,
      catalogItemId: catalogItemId,
    );

    if (existingIndex != null) {
      final current = _items[existingIndex];
      _items[existingIndex] = InvoiceItemModel(
        description: current.description,
        quantity: current.quantity + item.quantity,
        unitPrice: current.unitPrice,
      );

      if (catalogItemId != null) {
        _itemCatalogIds[existingIndex] = catalogItemId;
      }
      return;
    }

    _items.add(item);
    _itemCatalogIds.add(catalogItemId);
  }

  bool _isInvoiceItemSavedInCatalog(
    List<CatalogItemModel> catalogItems,
    int index,
  ) {
    if (_itemCatalogIds[index] != null) {
      return true;
    }

    final currentItem = _items[index];
    final normalizedDescription =
        _normalizeDescription(currentItem.description);

    for (final catalogItem in catalogItems) {
      if (catalogItem.normalizedDescription == normalizedDescription) {
        return true;
      }
    }

    return false;
  }

  void _syncLinkedInvoiceItemsFromCatalog(CatalogItemModel catalogItem) {
    bool changed = false;

    for (var i = 0; i < _items.length; i++) {
      if (_itemCatalogIds[i] == catalogItem.id) {
        final currentItem = _items[i];
        _items[i] = InvoiceItemModel(
          description: catalogItem.description,
          quantity: currentItem.quantity,
          unitPrice: catalogItem.unitPrice,
        );
        changed = true;
      }
    }

    if (changed && mounted) {
      setState(() {});
    }
  }

  void _unlinkDeletedCatalogItemFromActiveInvoice(String catalogItemId) {
    bool changed = false;

    for (var i = 0; i < _itemCatalogIds.length; i++) {
      if (_itemCatalogIds[i] == catalogItemId) {
        _itemCatalogIds[i] = null;
        changed = true;
      }
    }

    if (changed && mounted) {
      setState(() {});
    }
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _addItem() async {
    final result = await showAddItemDialog(
      context,
      catalogItems: ref.read(catalogItemsProvider),
    );
    if (result == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _addOrMergeInvoiceItem(
        item: result.item,
        catalogItemId: result.catalogItemId,
      );
    });
  }

  Future<void> _editItem(int index) async {
    final result = await showAddItemDialog(
      context,
      item: _items[index],
      catalogItems: ref.read(catalogItemsProvider),
      selectedCatalogItemId: _itemCatalogIds[index],
    );

    if (result != null) {
      setState(() {
        _items[index] = result.item;
        _itemCatalogIds[index] = result.catalogItemId;
      });
    }
  }

  void _removeItemAt(int index) {
    setState(() {
      _items.removeAt(index);
      _itemCatalogIds.removeAt(index);
    });
  }

  void _addCatalogItemToInvoice(CatalogItemModel item) {
    setState(() {
      _addOrMergeInvoiceItem(
        item: InvoiceItemModel(
          description: item.description,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        ),
        catalogItemId: item.id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.description} added')),
    );
  }

  double _resolvePaidAmount() {
    if (!_isInvoice || _isTemplateEdit) {
      return 0;
    }

    switch (_status) {
      case 'draft':
        return 0;
      case 'unpaid':
        return 0;
      case 'paid':
        return _total;
      case 'partial':
        return _paidAmount;
      default:
        return 0;
    }
  }

  String _resolveStatus() {
    if (!_isInvoice || _isTemplateEdit) {
      return 'draft';
    }

    return _status;
  }

  bool _validatePayment(AppLocalizations t) {
    if (!_showPaymentSection) {
      return true;
    }

    if (_status == 'partial') {
      if (_paidAmount <= 0 || _paidAmount >= _total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.enterValidPaidAmount)),
        );
        return false;
      }
    }

    if (_paidAmount > _total && _status == 'partial') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.paidAmountCannotExceedTotal)),
      );
      return false;
    }

    return true;
  }

  Future<String?> _promptTemplateName({
    String? initialValue,
  }) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: initialValue ?? '');

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t.templateName),
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

    return result;
  }

  Future<void> _showSaveCatalogItemDialog({
    CatalogItemModel? existingItem,
    InvoiceItemModel? sourceItem,
    int? sourceIndex,
  }) async {
    final isEditing = existingItem != null;
    final isFromInvoiceItem = sourceItem != null;
    final descriptionController = TextEditingController(
      text: existingItem?.description ?? sourceItem?.description ?? '',
    );
    final quantityController = TextEditingController(
      text: (existingItem?.quantity ?? 1).toString(),
    );
    final unitPriceController = TextEditingController(
      text: (existingItem?.unitPrice ?? sourceItem?.unitPrice ?? 0).toString(),
    );

    final notifier = ref.read(catalogItemsProvider.notifier);

    final result = await showDialog<CatalogItemModel>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? helperText;

        bool canSave() {
          final description = descriptionController.text.trim();

          if (description.isEmpty) {
            helperText = 'Description is required';
            return false;
          }

          final duplicate = notifier.findItemByDescription(
            description: description,
            excludeId: existingItem?.id,
          );

          if (duplicate != null) {
            helperText = 'Item already exists in catalog';
            return false;
          }

          helperText = null;
          return true;
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final saveEnabled = canSave();

            void revalidate() {
              setDialogState(() {});
            }

            return AlertDialog(
              title: Text(
                isEditing
                    ? 'Edit Product'
                    : isFromInvoiceItem
                        ? 'Save Product'
                        : 'Add Product',
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: descriptionController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => revalidate(),
                      ),
                      const SizedBox(height: 12),
                      if (isEditing) ...[
                        TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Default Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => revalidate(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: unitPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Unit Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => revalidate(),
                      ),
                      if (helperText != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            helperText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saveEnabled
                      ? () {
                          Navigator.of(dialogContext).pop(
                            CatalogItemModel(
                              id: existingItem?.id ?? const Uuid().v4(),
                              description: descriptionController.text.trim(),
                              quantity: isEditing
                                  ? (int.tryParse(quantityController.text.trim()) ??
                                          1)
                                      .clamp(1, 999999)
                                  : 1,
                              unitPrice:
                                  double.tryParse(unitPriceController.text.trim()) ??
                                      0,
                            ),
                          );
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    if (isEditing) {
      await notifier.updateItem(result);
      _syncLinkedInvoiceItemsFromCatalog(result);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated')),
      );
      return;
    }

    await notifier.addItem(result);

    if (sourceIndex != null &&
        sourceIndex >= 0 &&
        sourceIndex < _items.length &&
        sourceItem != null) {
      setState(() {
        _itemCatalogIds[sourceIndex] = result.id;
      });
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product saved to catalog')),
    );
  }

  Future<void> _deleteCatalogItem(CatalogItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${item.description}" from catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(catalogItemsProvider.notifier).deleteItem(item.id);
    _unlinkDeletedCatalogItemFromActiveInvoice(item.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted')),
    );
  }

  Future<void> _showCatalogBottomSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                final catalogItems = ref.watch(catalogItemsProvider);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Product Catalog',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _showSaveCatalogItemDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                        ),
                      ),
                    ),
                    if (catalogItems.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48),
                                SizedBox(height: 12),
                                Text(
                                  'No products yet',
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Add reusable items here for one-tap invoice entry',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: catalogItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = catalogItems[index];

                            return Card(
                              child: ListTile(
                                title: Text(item.description),
                                subtitle: Text(
                                  '${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Add to invoice',
                                      onPressed: () =>
                                          _addCatalogItemToInvoice(item),
                                      icon: const Icon(Icons.add_circle_outline),
                                    ),
                                    IconButton(
                                      tooltip: 'Edit product',
                                      onPressed: () => _showSaveCatalogItemDialog(
                                        existingItem: item,
                                      ),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete product',
                                      onPressed: () => _deleteCatalogItem(item),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  bool _validateTemplateInputs(AppLocalizations t) {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.clientRequired)),
      );
      return false;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.atLeastOneItem)),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveAsTemplateFromForm() async {
    final t = AppLocalizations.of(context)!;

    if (!_validateTemplateInputs(t)) {
      return;
    }

    final templateName = await _promptTemplateName(
      initialValue: widget.invoice?.templateName,
    );

    if (!mounted) return;

    if (templateName == null || templateName.trim().isEmpty) {
      return;
    }

    final template = InvoiceModel(
      id: const Uuid().v4(),
      invoiceNumber: '',
      clientId: _selectedClient!.id,
      issueDate: _issueDate,
      dueDate: _dueDate,
      items: _items
          .map(
            (item) => InvoiceItemModel(
              description: item.description,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          )
          .toList(),
      taxPercent: double.tryParse(_taxController.text.trim()) ?? 0,
      discount: double.tryParse(_discountController.text.trim()) ?? 0,
      notes: _notesController.text.trim(),
      status: 'draft',
      type: _isEdit ? widget.invoice!.type : widget.type,
      paidAmount: 0,
      convertedInvoiceId: null,
      isTemplate: true,
      templateName: templateName,
      isFavoriteTemplate: false,
    );

    await ref.read(invoicesProvider.notifier).addInvoice(template);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.templateSaved)),
    );
  }

  Future<void> _saveInvoice() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.clientRequired)),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.atLeastOneItem)),
      );
      return;
    }

    if (!_validatePayment(t)) {
      return;
    }

    if (_isTemplateEdit) {
      final updatedTemplate = InvoiceModel(
        id: widget.invoice!.id,
        invoiceNumber: '',
        clientId: _selectedClient!.id,
        issueDate: _issueDate,
        dueDate: _dueDate,
        items: _items
            .map(
              (item) => InvoiceItemModel(
                description: item.description,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
              ),
            )
            .toList(),
        taxPercent: double.tryParse(_taxController.text.trim()) ?? 0,
        discount: double.tryParse(_discountController.text.trim()) ?? 0,
        notes: _notesController.text.trim(),
        status: 'draft',
        type: widget.invoice!.type,
        paidAmount: 0,
        convertedInvoiceId: null,
        isTemplate: true,
        templateName: widget.invoice!.templateName,
        isFavoriteTemplate: widget.invoice!.isFavoriteTemplate,
      );

      await ref.read(invoicesProvider.notifier).updateInvoice(updatedTemplate);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.templateUpdated)),
      );
      Navigator.of(context).pop();
      return;
    }

    String finalDocumentNumber;

    if (_isEdit) {
      finalDocumentNumber = widget.invoice!.invoiceNumber;
    } else {
      final enteredNumber = _invoiceNumberController.text.trim();
      final numberingNotifier = ref.read(appSettingsProvider.notifier);
      final consumedGeneratedNumber =
          await numberingNotifier.consumeNextDocumentNumber(widget.type);
      finalDocumentNumber =
          enteredNumber.isEmpty ? consumedGeneratedNumber : enteredNumber;
    }

    final invoice = InvoiceModel(
      id: _isEdit ? widget.invoice!.id : const Uuid().v4(),
      invoiceNumber: finalDocumentNumber,
      clientId: _selectedClient!.id,
      issueDate: _issueDate,
      dueDate: _dueDate,
      items: _items
          .map(
            (item) => InvoiceItemModel(
              description: item.description,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          )
          .toList(),
      taxPercent: double.tryParse(_taxController.text.trim()) ?? 0,
      discount: double.tryParse(_discountController.text.trim()) ?? 0,
      notes: _notesController.text.trim(),
      status: _resolveStatus(),
      type: _isEdit ? widget.invoice!.type : widget.type,
      paidAmount: _resolvePaidAmount(),
      convertedInvoiceId: _isEdit ? widget.invoice?.convertedInvoiceId : null,
      isTemplate: false,
      templateName: null,
      isFavoriteTemplate: false,
    );

    if (_isEdit) {
      await ref.read(invoicesProvider.notifier).updateInvoice(invoice);
    } else {
      await ref.read(invoicesProvider.notifier).addInvoice(invoice);
    }

    if (!mounted) return;

    final selectedClient = _selectedClient!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? t.invoiceUpdated : t.invoiceSaved)),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => InvoicePreviewScreen(
          invoice: invoice,
          client: selectedClient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final clients = ref.watch(clientsProvider);
    final catalogItems = ref.watch(catalogItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isTemplateEdit
              ? t.editTemplate
              : _isEdit
                  ? (widget.type == 'quote' ? t.editQuote : t.editInvoice)
                  : (widget.type == 'quote' ? t.newQuote : t.createInvoice),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!_isTemplateEdit) ...[
              TextFormField(
                controller: _invoiceNumberController,
                readOnly: _isEdit,
                decoration: InputDecoration(
                  labelText: t.invoiceNumber,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<ClientModel>(
              value: clients.any((client) => client.id == _selectedClient?.id)
                  ? _selectedClient
                  : null,
              decoration: InputDecoration(
                labelText: t.selectClient,
                border: const OutlineInputBorder(),
              ),
              items: clients
                  .map(
                    (client) => DropdownMenuItem<ClientModel>(
                      value: client,
                      child: Text(client.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClient = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${t.issueDate}: ${_issueDate.toLocal().toString().split(' ').first}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _pickDate(
                  context: context,
                  initialDate: _issueDate,
                  onPicked: (date) => setState(() => _issueDate = date),
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${t.dueDate}: ${_dueDate.toLocal().toString().split(' ').first}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _pickDate(
                  context: context,
                  initialDate: _dueDate,
                  onPicked: (date) => setState(() => _dueDate = date),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.items,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _showCatalogBottomSheet,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Catalog'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: Text(t.addItem),
                ),
              ],
            ),
            if (_items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 40),
                      const SizedBox(height: 8),
                      Text(t.atLeastOneItem),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add),
                            label: Text(t.addItem),
                          ),
                          OutlinedButton.icon(
                            onPressed: _showCatalogBottomSheet,
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Catalog'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final itemAlreadyInCatalog =
                  _isInvoiceItemSavedInCatalog(catalogItems, index);

              return Card(
                child: ListTile(
                  title: Text(item.description),
                  subtitle: Text(
                    '${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} = ${item.total.toStringAsFixed(2)}',
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined),
                        onPressed: itemAlreadyInCatalog
                            ? null
                            : () => _showSaveCatalogItemDialog(
                                  sourceItem: item,
                                  sourceIndex: index,
                                ),
                        tooltip: itemAlreadyInCatalog
                            ? 'Already in catalog'
                            : 'Save to catalog',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editItem(index),
                        tooltip: t.edit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeItemAt(index),
                        tooltip: t.delete,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxController,
              decoration: InputDecoration(
                labelText: t.taxPercent,
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _discountController,
              decoration: InputDecoration(
                labelText: t.discount,
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (_showPaymentSection) ...[
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: t.paymentStatus,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'draft',
                    child: Text(t.statusDraft),
                  ),
                  DropdownMenuItem(
                    value: 'unpaid',
                    child: Text(t.statusUnpaid),
                  ),
                  DropdownMenuItem(
                    value: 'partial',
                    child: Text(t.statusPartial),
                  ),
                  DropdownMenuItem(
                    value: 'paid',
                    child: Text(t.statusPaid),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _status = value;
                    if (_status == 'draft' || _status == 'unpaid') {
                      _paidAmountController.text = '0';
                    } else if (_status == 'paid') {
                      _paidAmountController.text = _total.toStringAsFixed(2);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paidAmountController,
                enabled: _status == 'partial',
                decoration: InputDecoration(
                  labelText: t.paidAmount,
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: t.notes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SummaryRow(label: t.subtotal, value: _subtotal),
                    const SizedBox(height: 8),
                    _SummaryRow(label: t.tax, value: _taxAmount),
                    const SizedBox(height: 8),
                    _SummaryRow(label: t.discount, value: _discount),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: t.total,
                      value: _total,
                      isBold: true,
                    ),
                    if (_showPaymentSection) ...[
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: t.paidAmount,
                        value: _status == 'paid'
                            ? _total
                            : _status == 'partial'
                                ? _paidAmount
                                : 0,
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: t.remainingAmount,
                        value: _status == 'paid'
                            ? 0
                            : _status == 'partial'
                                ? _remainingAmount
                                : _total,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isTemplateEdit) ...[
              OutlinedButton.icon(
                onPressed: _saveAsTemplateFromForm,
                icon: const Icon(Icons.bookmark_border),
                label: Text(t.saveAsTemplate),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: _saveInvoice,
              child: Text(_isEdit ? t.saveChanges : t.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final double value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value.toStringAsFixed(2), style: style),
      ],
    );
  }
}