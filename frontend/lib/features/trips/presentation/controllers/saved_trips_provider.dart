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
  String? _cacheUserId;
  bool _isDisposed = false;
  int _loadRequestId = 0;

  SavedTripsStatus get status => _status;
  List<SavedTrip> get trips => _trips;
  String? get errorMessage => _errorMessage;
  String? get deletingTripId => _deletingTripId;
  bool get isLoading => _status == SavedTripsStatus.loading;

  Future<void> loadTrips({
    required String idToken,
    required String userId,
    bool forceRefresh = false,
  }) async {
    final requestId = ++_loadRequestId;
    _cacheUserId = userId;
    _status = SavedTripsStatus.loading;
    _errorMessage = null;
    _notifyIfActive();

    try {
      final trips = await _tripsService.fetchTrips(
        idToken: idToken,
        userId: userId,
        forceRefresh: forceRefresh,
      );
      if (_isDisposed || requestId != _loadRequestId) {
        return;
      }
      _trips = trips;
      _status = SavedTripsStatus.success;
    } on SavedTripsException catch (error) {
      if (_isDisposed || requestId != _loadRequestId) {
        return;
      }
      _errorMessage = error.message;
      _status = SavedTripsStatus.error;
    } catch (_) {
      if (_isDisposed || requestId != _loadRequestId) {
        return;
      }
      _errorMessage = 'We could not load saved trips.';
      _status = SavedTripsStatus.error;
    }

    _notifyIfActive();
  }

  Future<void> deleteTrip({
    required String idToken,
    required String tripId,
  }) async {
    final userId = _cacheUserId;
    _deletingTripId = tripId;
    _errorMessage = null;
    _notifyIfActive();

    try {
      await _tripsService.deleteTrip(
        idToken: idToken,
        userId: userId ?? '',
        tripId: tripId,
      );
      if (_isDisposed) {
        return;
      }
      _trips = _trips.where((trip) => trip.id != tripId).toList();
    } on SavedTripsException catch (error) {
      if (_isDisposed) {
        return;
      }
      _errorMessage = error.message;
      _status = SavedTripsStatus.error;
    } catch (_) {
      if (_isDisposed) {
        return;
      }
      _errorMessage = 'We could not delete the trip.';
      _status = SavedTripsStatus.error;
    }

    _deletingTripId = null;
    _notifyIfActive();
  }

  void _notifyIfActive() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _loadRequestId++;
    super.dispose();
  }
}
