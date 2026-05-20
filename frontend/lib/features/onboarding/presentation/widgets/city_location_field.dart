import 'package:flutter/material.dart';

import '../../data/city_catalog.dart';
import '../../data/country_catalog.dart';
import '../../domain/city_location_constants.dart';
import '../../domain/city_option.dart';

part 'city_location_field_state.dart';
part 'city_suggestions.dart';

class CityLocationField extends StatefulWidget {
  const CityLocationField({
    super.key,
    required this.value,
    required this.country,
    required this.onChanged,
    this.errorText,
    CityCatalog? cityCatalog,
    CountryCatalog? countryCatalog,
  }) : _cityCatalog = cityCatalog,
       _countryCatalog = countryCatalog;

  final String value;
  final String country;
  final Future<void> Function(String value) onChanged;
  final String? errorText;
  final CityCatalog? _cityCatalog;
  final CountryCatalog? _countryCatalog;

  @override
  State<CityLocationField> createState() => _CityLocationFieldState();
}
