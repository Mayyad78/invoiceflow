import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client_model.dart';
import '../../models/invoice_item_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/invoices_provider.dart';
import 'invoice_preview_screen.dart';
import 'widgets/add_item_dialog.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({
    super.key,
    this.type = 'invoice',
    this.invoice,
  });

  final String type;
  final InvoiceModel? invoice;

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

  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  ClientModel? _selectedClient;
  final List<InvoiceItemModel> _items = [];
  late String _initialGeneratedNumber;

  bool get _isEdit => widget.invoice != null;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      final invoice = widget.invoice!;
      _invoiceNumberController.text = invoice.invoiceNumber;
      _taxController.text = invoice.taxPercent.toString();
      _discountController.text = invoice.discount.toString();
      _notesController.text = invoice.notes;
      _issueDate = invoice.issueDate;
      _dueDate = invoice.dueDate;
      _items.addAll(invoice.items.cast<InvoiceItemModel>());
      _initialGeneratedNumber = invoice.invoiceNumber;
    } else {
      final settingsNotifier = ref.read(appSettingsProvider.notifier);
      _initialGeneratedNumber =
          settingsNotifier.previewDocumentNumber(widget.type);
      _invoiceNumberController.text = _initialGeneratedNumber;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_selectedClient != null || !_isEdit) return;

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
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  double get _taxAmount =>
      _subtotal * ((double.tryParse(_taxController.text) ?? 0) / 100);

  double get _discount => double.tryParse(_discountController.text) ?? 0;

  double get _total => _subtotal + _taxAmount - _discount;

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
    final item = await showAddItemDialog(context);
    if (item != null) {
      setState(() {
        _items.add(item);
      });
    }
  }

  Future<void> _editItem(int index) async {
    final updatedItem = await showAddItemDialog(
      context,
      item: _items[index],
    );

    if (updatedItem != null) {
      setState(() {
        _items[index] = updatedItem;
      });
    }
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
      id: widget.invoice?.id ?? const Uuid().v4(),
      invoiceNumber: finalDocumentNumber,
      clientId: _selectedClient!.id,
      issueDate: _issueDate,
      dueDate: _dueDate,
      items: List<InvoiceItemModel>.from(_items),
      taxPercent: double.tryParse(_taxController.text.trim()) ?? 0,
      discount: double.tryParse(_discountController.text.trim()) ?? 0,
      notes: _notesController.text.trim(),
      status: widget.invoice?.status ?? 'draft',
      type: widget.invoice?.type ?? widget.type,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit
              ? (widget.type == 'quote' ? t.editQuote : t.editInvoice)
              : (widget.type == 'quote' ? t.newQuote : t.createInvoice),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: Text(t.addItem),
                ),
              ],
            ),
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(t.atLeastOneItem),
              ),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

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
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editItem(index),
                        tooltip: t.edit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            _items.removeAt(index);
                          });
                        },
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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