part of 'backend_saved_trips_service.dart';

class SavedTripsException implements Exception {
  const SavedTripsException(this.message);

  final String message;

  @override
  String toString() => message;
}
