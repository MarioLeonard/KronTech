import 'package:flutter/material.dart';

class CityLocationConstants {
  const CityLocationConstants._();

  static const hintText = 'Type your city';
  static const noCountryText = 'Select a country first.';
  static const noMatchesText = 'No matching cities';
  static const minCityQueryLength = 2;
  static const maxCitySuggestions = 6;
  static const suggestionsAnimationDuration = Duration(milliseconds: 240);
  static const suggestionsAnimationCurve = Curves.easeOutCubic;
}
