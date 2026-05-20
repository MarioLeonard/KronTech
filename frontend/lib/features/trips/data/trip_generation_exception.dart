part of 'backend_trip_generation_service.dart';

class TripGenerationException implements Exception {
  const TripGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}
