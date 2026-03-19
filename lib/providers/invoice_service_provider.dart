import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/invoice_service.dart';

final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  return InvoiceService();
});