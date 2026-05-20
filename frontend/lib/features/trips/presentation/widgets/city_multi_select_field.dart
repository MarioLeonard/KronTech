import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

part 'city_multi_select_field_state.dart';
part 'city_suggestions.dart';
part 'city_suggestion_tile.dart';

class CityMultiSelectField extends StatefulWidget {
  const CityMultiSelectField({
    required this.cities,
    required this.onChanged,
    required this.enabled,
    super.key,
  });

  final List<String> cities;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  @override
  State<CityMultiSelectField> createState() => _CityMultiSelectFieldState();
}
