class CatalogItemModel {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;

  CatalogItemModel({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  String get normalizedDescription => description.trim().toLowerCase();

  CatalogItemModel copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
  }) {
    return CatalogItemModel(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory CatalogItemModel.fromMap(Map<dynamic, dynamic> map) {
    final rawQuantity = map['quantity'];
    final rawUnitPrice = map['unitPrice'];

    return CatalogItemModel(
      id: map['id']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      quantity: rawQuantity is int
          ? rawQuantity
          : int.tryParse(rawQuantity?.toString() ?? '') ?? 1,
      unitPrice: rawUnitPrice is num
          ? rawUnitPrice.toDouble()
          : double.tryParse(rawUnitPrice?.toString() ?? '') ?? 0,
    );
  }
}