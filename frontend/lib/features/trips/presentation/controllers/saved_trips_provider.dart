import 'package:flutter/foundation.dart';
import 'package:frontend/features/trips/data/backend_saved_trips_service.dart';
import 'package:frontend/features/trips/domain/saved_trip.dart';

enum SavedTripsStatus { idle, loading, success, error }

class SavedTripsProvider extends ChangeNotifier {
  SavedTripsProvider({BackendSavedTripsService? tripsService})
    : _tripsService = tripsService ?? BackendSavedTripsService();

  final BackendSavedTripsService _tripsService;

  SavedTripsStatus _status = SavedTripsStatus.idle;
  List<SavedTrip> _trips = const [];
  String? _errorMessage;
  String? _deletingTripId;

  SavedTripsStatus get status => _status;
  List<SavedTrip> get trips => _trips;
  String? get errorMessage => _errorMessage;
  String? get deletingTripId => _deletingTripId;
  bool get isLoading => _status == SavedTripsStatus.loading;

  Future<void> loadTrips(String idToken) async {
    _status = SavedTripsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _trips = await _tripsService.fetchTrips(idToken);
      _status = SavedTripsStatus.success;
    } on SavedTripsException catch (error) {
      _errorMessage = error.message;
      _status = SavedTripsStatus.error;
    } catch (_) {
      _errorMessage = 'Nu am putut incarca tripurile salvate.';
      _status = SavedTripsStatus.error;
    }

    notifyListeners();
  }

  Future<void> deleteTrip({
    required String idToken,
    required String tripId,
  }) async {
    _deletingTripId = tripId;
    _errorMessage = null;
    notifyListeners();

    try {
      await _tripsService.deleteTrip(idToken: idToken, tripId: tripId);
      _trips = _trips.where((trip) => trip.id != tripId).toList();
    } on SavedTripsException catch (error) {
      _errorMessage = error.message;
      _status = SavedTripsStatus.error;
    } catch (_) {
      _errorMessage = 'Nu am putut sterge tripul.';
      _status = SavedTripsStatus.error;
    }

    _deletingTripId = null;
    notifyListeners();
  }
}
