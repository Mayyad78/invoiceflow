import 'invoice_item_model.dart';

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String clientId;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItemModel> items;
  final double taxPercent;
  final double discount;
  final String notes;
  final String status;
  final String type;
  final double paidAmount;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.issueDate,
    required this.dueDate,
    required this.items,
    required this.taxPercent,
    required this.discount,
    required this.notes,
    required this.status,
    required this.type,
    required this.paidAmount,
  });

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  double get taxAmount {
    return subtotal * (taxPercent / 100);
  }

  double get total {
    return subtotal + taxAmount - discount;
  }

  double get remainingAmount {
    final remaining = total - paidAmount;
    return remaining < 0 ? 0 : remaining;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'clientId': clientId,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'items': items.map((e) => e.toMap()).toList(),
      'taxPercent': taxPercent,
      'discount': discount,
      'notes': notes,
      'status': status,
      'type': type,
      'paidAmount': paidAmount,
    };
  }

  factory InvoiceModel.fromMap(Map map) {
    return InvoiceModel(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      clientId: map['clientId'] ?? '',
      issueDate: DateTime.tryParse(map['issueDate'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now(),
      items: (map['items'] as List? ?? [])
          .map((e) => InvoiceItemModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      taxPercent: (map['taxPercent'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'draft',
      type: map['type'] ?? 'invoice',
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
    );
  }
}