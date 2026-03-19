import 'package:hive/hive.dart';

import '../models/invoice_model.dart';
import 'local_storage_service.dart';

class InvoiceService {
  final Box _box = LocalStorageService.getInvoicesBox();

  List<InvoiceModel> getInvoices() {
    return _box.values
        .map((e) => InvoiceModel.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveInvoice(InvoiceModel invoice) async {
    await _box.put(invoice.id, invoice.toMap());
  }

  Future<void> deleteInvoice(String id) async {
    await _box.delete(id);
  }
}