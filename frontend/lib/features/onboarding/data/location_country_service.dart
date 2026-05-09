import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../domain/country_location_constants.dart';
import '../domain/location_place.dart';

class LocationCountryService {
  const LocationCountryService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<LocationPlace> detectPlace() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationCountryException(
        CountryLocationConstants.locationServicesDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationCountryException(
        CountryLocationConstants.locationPermissionRequired,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );

    return _placeFromCoordinates(position);
  }

  Future<LocationPlace> _placeFromCoordinates(Position position) async {
    final uri = Uri.https(
      CountryLocationConstants.reverseGeocodeHost,
      CountryLocationConstants.reverseGeocodePath,
      {
        'format': CountryLocationConstants.reverseGeocodeFormat,
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'lat': position.latitude.toString(),
        'lon': position.longitude.toString(),
        'zoom': CountryLocationConstants.reverseGeocodeZoom,
        'addressdetails': '1',
      },
    );
    final ownsClient = _client == null;
    final client = _client ?? http.Client();
    final response = await client.get(
      uri,
      headers: const {'User-Agent': CountryLocationConstants.appUserAgent},
    );
    if (ownsClient) {
      client.close();
    }

    if (response.statusCode != 200) {
      throw const LocationCountryException(
        CountryLocationConstants.placeLookupFailed,
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final address = payload['address'] as Map<String, dynamic>?;
    final country = address?['country'] as String?;
    final city =
        address?['city'] as String? ??
        address?['town'] as String? ??
        address?['village'] as String? ??
        address?['municipality'] as String? ??
        address?['county'] as String?;
    final road =
        address?['road'] as String? ??
        address?['pedestrian'] as String? ??
        address?['footway'] as String? ??
        address?['residential'] as String?;
    final houseNumber = address?['house_number'] as String?;
    if (country == null || country.trim().isEmpty) {
      throw const LocationCountryException(
        CountryLocationConstants.placeLookupFailed,
      );
    }

    return LocationPlace(
      country: country.trim(),
      city: city?.trim() ?? '',
      street: _formatStreet(road: road, houseNumber: houseNumber),
    );
  }

  String _formatStreet({String? road, String? houseNumber}) {
    final streetName = road?.trim() ?? '';
    final number = houseNumber?.trim() ?? '';
    if (streetName.isEmpty) {
      return '';
    }

    if (number.isEmpty) {
      return streetName;
    }

    return '$streetName $number';
  }
}

class LocationCountryException implements Exception {
  const LocationCountryException(this.message);

  final String message;
}
