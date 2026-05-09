import 'package:country_state_city/country_state_city.dart' as csc;

import '../domain/city_location_constants.dart';
import '../domain/city_option.dart';

class CityCatalog {
  final Map<String, List<CityOption>> _citiesByCountryCode = {};

  Future<List<CityOption>> suggestionsFor({
    required String countryCode,
    required String query,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (countryCode.isEmpty ||
        normalized.length < CityLocationConstants.minCityQueryLength) {
      return const [];
    }

    final cities = await _loadCities(countryCode);
    return cities
        .where((city) => city.name.toLowerCase().contains(normalized))
        .take(CityLocationConstants.maxCitySuggestions)
        .toList();
  }

  Future<List<CityOption>> _loadCities(String countryCode) async {
    final normalizedCode = countryCode.toUpperCase();
    final cached = _citiesByCountryCode[normalizedCode];
    if (cached != null) {
      return cached;
    }

    final cities = await csc.getCountryCities(normalizedCode);
    final options =
        cities.map((city) => CityOption(name: city.name)).toSet().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    _citiesByCountryCode[normalizedCode] = options;
    return options;
  }
}
