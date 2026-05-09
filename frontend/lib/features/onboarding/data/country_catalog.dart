import 'package:country_picker/country_picker.dart';

import '../domain/country_location_constants.dart';
import '../domain/country_option.dart';

class CountryCatalog {
  CountryCatalog({CountryService? countryService})
    : _countryService = countryService ?? CountryService();

  final CountryService _countryService;

  late final List<CountryOption> _options = [
    ..._countryService.getAll().map(
      (country) => CountryOption(name: country.name, code: country.countryCode),
    ),
    ...countryAliases.entries.map(
      (alias) => CountryOption(name: alias.key, code: alias.value),
    ),
  ]..sort((a, b) => a.name.compareTo(b.name));

  List<CountryOption> suggestionsFor(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.length < CountryLocationConstants.minCountryQueryLength) {
      return const [];
    }

    return _options
        .where((country) {
          final name = country.name.toLowerCase();
          final code = country.code?.toLowerCase() ?? '';
          return name.contains(normalized) || code.contains(normalized);
        })
        .take(CountryLocationConstants.maxCountrySuggestions)
        .toList();
  }

  String countryCodeFor(String countryName) {
    final normalized = countryName.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }

    for (final country in _options) {
      if (country.name.toLowerCase() == normalized) {
        return country.code ?? '';
      }
    }

    return '';
  }
}
