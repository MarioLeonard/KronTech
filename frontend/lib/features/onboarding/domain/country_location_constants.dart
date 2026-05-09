import 'package:flutter/material.dart';

class CountryLocationConstants {
  const CountryLocationConstants._();

  static const hintText = 'Type your country';
  static const locationTooltip = 'Use my location';
  static const noMatchesText = 'No matching countries';
  static const locationFallbackError =
      'Could not detect your country. Type it manually instead.';
  static const locationServicesDisabled = 'Location services are turned off.';
  static const locationPermissionRequired = 'Location permission is required.';
  static const placeLookupFailed = 'Location lookup failed.';

  static const reverseGeocodeHost = 'nominatim.openstreetmap.org';
  static const reverseGeocodePath = '/reverse';
  static const reverseGeocodeFormat = 'jsonv2';
  static const reverseGeocodeZoom = '18';
  static const appUserAgent = 'KronTech onboarding';

  static const minCountryQueryLength = 2;
  static const maxCountrySuggestions = 6;
  static const suggestionsAnimationDuration = Duration(milliseconds: 240);
  static const suggestionsAnimationCurve = Curves.easeOutCubic;
}

const countryAliases = {
  'England': 'GB',
  'Scotland': 'GB',
  'Wales': 'GB',
  'Northern Ireland': 'GB',
};
