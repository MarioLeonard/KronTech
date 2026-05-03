import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/objective.dart';
import '../services/routing_service.dart';

class RouteState {
  const RouteState({
    this.polylinePoints = const [],
    this.totalDistanceKm,
    this.totalDurationMin,
    this.isLoading = false,
    this.error,
  });

  final List<LatLng> polylinePoints;
  final double? totalDistanceKm;
  final double? totalDurationMin;
  final bool isLoading;
  final String? error;

  bool get hasRoute => polylinePoints.isNotEmpty;

  RouteState copyWith({
    List<LatLng>? polylinePoints,
    double? totalDistanceKm,
    double? totalDurationMin,
    bool? isLoading,
    String? error,
  }) {
    return RouteState(
      polylinePoints: polylinePoints ?? this.polylinePoints,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalDurationMin: totalDurationMin ?? this.totalDurationMin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RouteProvider extends ChangeNotifier {
  RouteProvider(this._service);

  final RoutingService _service;
  RouteState _state = const RouteState();

  RouteState get state => _state;

  void setLoading(bool value) {
    _state = _state.copyWith(isLoading: value, error: null);
    notifyListeners();
  }

  void setRoute({
    required List<LatLng> points,
    double? distanceKm,
    double? durationMin,
  }) {
    _state = _state.copyWith(
      polylinePoints: points,
      totalDistanceKm: distanceKm,
      totalDurationMin: durationMin,
      isLoading: false,
      error: null,
    );
    notifyListeners();
  }

  void setError(String message) {
    _state = _state.copyWith(isLoading: false, error: message);
    notifyListeners();
  }

  Future<void> buildRoute(List<Objective> stops) async {
    if (stops.length < 2) {
      return;
    }

    setLoading(true);
    try {
      final result = await _service.getRoute(stops);
      setRoute(
        points: result.polylinePoints,
        distanceKm: result.distanceKm,
        durationMin: result.durationMin,
      );
    } catch (error) {
      setError(error.toString());
    }
  }

  void clearRoute() {
    _state = const RouteState();
    notifyListeners();
  }
}
