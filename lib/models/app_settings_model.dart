class AppSettingsModel {
  final String currency;

  const AppSettingsModel({
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
    };
  }

  factory AppSettingsModel.fromMap(Map<dynamic, dynamic> map) {
    return AppSettingsModel(
      currency: map['currency'] ?? 'USD',
    );
  }

  AppSettingsModel copyWith({
    String? currency,
  }) {
    return AppSettingsModel(
      currency: currency ?? this.currency,
    );
  }
}