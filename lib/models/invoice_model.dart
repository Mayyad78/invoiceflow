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
  final String? convertedInvoiceId;
  final bool isTemplate;
  final String? templateName;

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
    this.convertedInvoiceId,
    this.isTemplate = false,
    this.templateName,
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

  bool get isConvertedQuote {
    return type == 'quote' &&
        convertedInvoiceId != null &&
        convertedInvoiceId!.trim().isNotEmpty;
  }

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? clientId,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceItemModel>? items,
    double? taxPercent,
    double? discount,
    String? notes,
    String? status,
    String? type,
    double? paidAmount,
    String? convertedInvoiceId,
    bool? isTemplate,
    String? templateName,
    bool clearConvertedInvoiceId = false,
    bool clearTemplateName = false,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      taxPercent: taxPercent ?? this.taxPercent,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      type: type ?? this.type,
      paidAmount: paidAmount ?? this.paidAmount,
      convertedInvoiceId: clearConvertedInvoiceId
          ? null
          : (convertedInvoiceId ?? this.convertedInvoiceId),
      isTemplate: isTemplate ?? this.isTemplate,
      templateName: clearTemplateName
          ? null
          : (templateName ?? this.templateName),
    );
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
      'convertedInvoiceId': convertedInvoiceId,
      'isTemplate': isTemplate,
      'templateName': templateName,
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
      convertedInvoiceId: map['convertedInvoiceId']?.toString(),
      isTemplate: map['isTemplate'] ?? false,
      templateName: map['templateName']?.toString(),
    );
  }
}