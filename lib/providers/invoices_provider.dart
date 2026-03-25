import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/invoice_model.dart';
import 'invoice_service_provider.dart';

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, List<InvoiceModel>>(
  (ref) {
    final service = ref.watch(invoiceServiceProvider);
    return InvoicesNotifier(service)..loadInvoices();
  },
);

class InvoicesNotifier extends StateNotifier<List<InvoiceModel>> {
  InvoicesNotifier(this._invoiceService) : super([]);

  final dynamic _invoiceService;

  void loadInvoices() {
    state = _invoiceService.getInvoices();
  }

  Future<void> addInvoice(InvoiceModel invoice) async {
    await _invoiceService.saveInvoice(invoice);
    loadInvoices();
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    await _invoiceService.updateInvoice(invoice);
    loadInvoices();
  }

  Future<void> deleteInvoice(String id) async {
    await _invoiceService.deleteInvoice(id);
    loadInvoices();
  }
}