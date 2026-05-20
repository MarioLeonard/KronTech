import 'package:flutter/material.dart';

import '../../data/country_catalog.dart';
import '../../data/location_country_service.dart';
import '../../domain/country_location_constants.dart';
import '../../domain/country_option.dart';

part 'country_location_field_state.dart';
part 'country_suggestions.dart';

class CountryLocationField extends StatefulWidget {
  const CountryLocationField({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.onLocationDetected,
    CountryCatalog? countryCatalog,
    LocationCountryService? locationCountryService,
  }) : _countryCatalog = countryCatalog,
       _locationCountryService = locationCountryService;

  final String value;
  final Future<void> Function(String value) onChanged;
  final String? errorText;
  final Future<void> Function(String country, String city, String street)?
  onLocationDetected;
  final CountryCatalog? _countryCatalog;
  final LocationCountryService? _locationCountryService;

  @override
  State<CountryLocationField> createState() => _CountryLocationFieldState();
}
