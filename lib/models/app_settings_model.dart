class AppSettingsModel {
  final String currency;
  final String invoicePrefix;
  final String quotePrefix;
  final int nextInvoiceNumber;
  final int nextQuoteNumber;

  const AppSettingsModel({
    required this.currency,
    required this.invoicePrefix,
    required this.quotePrefix,
    required this.nextInvoiceNumber,
    required this.nextQuoteNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'invoicePrefix': invoicePrefix,
      'quotePrefix': quotePrefix,
      'nextInvoiceNumber': nextInvoiceNumber,
      'nextQuoteNumber': nextQuoteNumber,
    };
  }

  factory AppSettingsModel.fromMap(Map map) {
    return AppSettingsModel(
      currency: _readString(map['currency'], fallback: 'USD'),
      invoicePrefix: _readString(map['invoicePrefix'], fallback: 'INV-'),
      quotePrefix: _readString(map['quotePrefix'], fallback: 'QUO-'),
      nextInvoiceNumber: _readInt(map['nextInvoiceNumber'], fallback: 1),
      nextQuoteNumber: _readInt(map['nextQuoteNumber'], fallback: 1),
    );
  }

  AppSettingsModel copyWith({
    String? currency,
    String? invoicePrefix,
    String? quotePrefix,
    int? nextInvoiceNumber,
    int? nextQuoteNumber,
  }) {
    return AppSettingsModel(
      currency: currency ?? this.currency,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      quotePrefix: quotePrefix ?? this.quotePrefix,
      nextInvoiceNumber: nextInvoiceNumber ?? this.nextInvoiceNumber,
      nextQuoteNumber: nextQuoteNumber ?? this.nextQuoteNumber,
    );
  }

  static String _readString(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? fallback;
  }
}