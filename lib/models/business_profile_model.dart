class BusinessProfileModel {
  final String name;
  final String email;
  final String phone;
  final String address;

  const BusinessProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }

  factory BusinessProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return BusinessProfileModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }

  BusinessProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) {
    return BusinessProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}