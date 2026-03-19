class InvoiceItemModel {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItemModel({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory InvoiceItemModel.fromMap(Map<dynamic, dynamic> map) {
    return InvoiceItemModel(
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    );
  }
}