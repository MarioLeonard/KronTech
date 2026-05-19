import 'dart:async';

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
  final Map<String, Timer> _syncTimers = {};
  final Map<String, SavedTrip> _pendingSyncTrips = {};

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

  SavedTrip? updatePlaceVisited({
    required String tripId,
    required int dayNumber,
    required int activityIndex,
    required bool isVisited,
    required String idToken,
    required String userId,
  }) {
    _cacheUserId = userId;
    SavedTrip? updatedTrip;

    _trips = [
      for (final trip in _trips)
        if (trip.id == tripId)
          updatedTrip = _copyTripWithVisitedPlace(
            trip: trip,
            dayNumber: dayNumber,
            activityIndex: activityIndex,
            isVisited: isVisited,
          )
        else
          trip,
    ];

    if (updatedTrip == null) {
      return null;
    }

    _updateCacheQuietly(userId: userId, trip: updatedTrip);
    _scheduleRemoteSync(trip: updatedTrip, idToken: idToken, userId: userId);
    _notifyIfActive();
    return updatedTrip;
  }

  SavedTrip _copyTripWithVisitedPlace({
    required SavedTrip trip,
    required int dayNumber,
    required int activityIndex,
    required bool isVisited,
  }) {
    final itinerary = trip.itinerary;
    if (itinerary == null) {
      return trip;
    }

    final days = [
      for (final day in itinerary.days)
        if (day.dayNumber == dayNumber)
          day.copyWith(
            activities: [
              for (var index = 0; index < day.activities.length; index++)
                if (index == activityIndex)
                  day.activities[index].copyWith(isVisited: isVisited)
                else
                  day.activities[index],
            ],
          )
        else
          day,
    ];

    return trip.copyWith(itinerary: itinerary.copyWith(days: days));
  }

  void _scheduleRemoteSync({
    required SavedTrip trip,
    required String idToken,
    required String userId,
  }) {
    _pendingSyncTrips[trip.id] = trip;
    _syncTimers[trip.id]?.cancel();
    _syncTimers[trip.id] = Timer(const Duration(seconds: 3), () {
      _syncVisitedPlaces(tripId: trip.id, idToken: idToken, userId: userId);
    });
  }

  void _updateCacheQuietly({required String userId, required SavedTrip trip}) {
    _tripsService.updateCachedTrip(userId: userId, trip: trip).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      if (kDebugMode) {
        debugPrint('[SavedTripsProvider] Cache update failed: $error');
      }
    });
  }

  Future<void> _syncVisitedPlaces({
    required String tripId,
    required String idToken,
    required String userId,
  }) async {
    final trip = _pendingSyncTrips.remove(tripId);
    _syncTimers.remove(tripId)?.cancel();
    if (trip == null || _isDisposed) {
      return;
    }

    try {
      final syncedTrip = await _tripsService.updateTripItinerary(
        idToken: idToken,
        userId: userId,
        trip: trip,
      );
      if (_isDisposed) {
        return;
      }
      _trips = [
        for (final currentTrip in _trips)
          currentTrip.id == syncedTrip.id ? syncedTrip : currentTrip,
      ];
      _notifyIfActive();
    } on SavedTripsException catch (error) {
      if (_isDisposed) {
        return;
      }
      _errorMessage = error.message;
      _notifyIfActive();
    } catch (_) {
      if (_isDisposed) {
        return;
      }
      _errorMessage = 'We could not sync visited places yet.';
      _notifyIfActive();
    }
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
    for (final timer in _syncTimers.values) {
      timer.cancel();
    }
    _syncTimers.clear();
    _pendingSyncTrips.clear();
    super.dispose();
  }
}
