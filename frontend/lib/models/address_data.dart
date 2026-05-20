part of 'onboarding_data.dart';

class AddressData {
  final String country;
  final String city;
  final String street;
  final String zipCode;

  AddressData({
    required this.country,
    required this.city,
    required this.street,
    required this.zipCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'city': city,
      'street': street,
      'zipCode': zipCode,
    };
  }

  factory AddressData.fromMap(Map<String, dynamic> map) {
    return AddressData(
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      street: map['street'] ?? '',
      zipCode: map['zipCode'] ?? '',
    );
  }

  factory AddressData.empty() {
    return AddressData(country: '', city: '', street: '', zipCode: '');
  }

  AddressData copyWith({
    String? country,
    String? city,
    String? street,
    String? zipCode,
  }) {
    return AddressData(
      country: country ?? this.country,
      city: city ?? this.city,
      street: street ?? this.street,
      zipCode: zipCode ?? this.zipCode,
    );
  }

  bool get isValid =>
      country.isNotEmpty && city.isNotEmpty && street.isNotEmpty;
}
