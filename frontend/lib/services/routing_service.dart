import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/objective.dart';

class RouteResult {
  const RouteResult({
    required this.polylinePoints,
    required this.distanceKm,
    required this.durationMin,
  });

  final List<LatLng> polylinePoints;
  final double distanceKm;
  final double durationMin;
}

class RoutingService {
  static const _baseUrl = 'http://router.project-osrm.org/route/v1/driving';

  Future<RouteResult> getRoute(List<Objective> stops) async {
    if (stops.length < 2) {
      throw ArgumentError('Need at least 2 stops');
    }

    final coords = stops.map((s) => '${s.lng},${s.lat}').join(';');
    final uri = Uri.parse(
      '$_baseUrl/$coords?overview=full&geometries=geojson&steps=false',
    );

    final response = await http.get(uri, headers: const {
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('OSRM returned ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['code'] != 'Ok') {
      throw Exception('OSRM error: ${data['message']}');
    }

    final route = (data['routes'] as List).first as Map<String, dynamic>;
    final distanceKm = (route['distance'] as num) / 1000.0;
    final durationMin = (route['duration'] as num) / 60.0;
    final geoJson = route['geometry'] as Map<String, dynamic>;
    final coordinates = (geoJson['coordinates'] as List)
        .map((c) => LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            ))
        .toList();

    return RouteResult(
      polylinePoints: coordinates,
      distanceKm: distanceKm,
      durationMin: durationMin,
    );
  }
}
