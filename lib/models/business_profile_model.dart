import 'dart:convert';
import 'dart:typed_data';

class BusinessProfileModel {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? logoBase64;

  const BusinessProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.logoBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'logoBase64': logoBase64,
    };
  }

  factory BusinessProfileModel.fromMap(Map map) {
    return BusinessProfileModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      logoBase64: map['logoBase64'],
    );
  }

  BusinessProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? logoBase64,
    bool clearLogo = false,
  }) {
    return BusinessProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logoBase64: clearLogo ? null : (logoBase64 ?? this.logoBase64),
    );
  }

  Uint8List? get logoBytes {
    final value = logoBase64;
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  bool get hasLogo => logoBytes != null;
}