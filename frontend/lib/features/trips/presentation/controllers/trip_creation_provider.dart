import 'package:flutter/foundation.dart';
import 'package:frontend/features/trips/data/backend_trip_generation_service.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';

enum TripCreationStatus { idle, loading, success, error }

class TripCreationProvider extends ChangeNotifier {
  TripCreationProvider({BackendTripGenerationService? tripService})
    : _tripService = tripService ?? BackendTripGenerationService();

  final BackendTripGenerationService _tripService;

  TripCreationStatus _status = TripCreationStatus.idle;
  GeneratedTrip? _trip;
  TripCreationRequest? _lastRequest;
  String? _lastIdToken;
  String? _errorMessage;
  bool _isDisposed = false;
  int _generationRequestId = 0;

  TripCreationStatus get status => _status;
  GeneratedTrip? get trip => _trip;
  TripCreationRequest? get lastRequest => _lastRequest;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TripCreationStatus.loading;

  Future<void> generateTrip({
    required TripCreationRequest request,
    required String idToken,
  }) async {
    final requestId = ++_generationRequestId;
    _status = TripCreationStatus.loading;
    _lastRequest = request;
    _lastIdToken = idToken;
    _errorMessage = null;
    _notifyIfActive();

    try {
      final generatedTrip = await _tripService.generateTrip(
        request: request,
        idToken: idToken,
      );
      if (_isDisposed || requestId != _generationRequestId) {
        return;
      }
      _trip = generatedTrip;
      _status = TripCreationStatus.success;
    } on TripGenerationException catch (error) {
      if (_isDisposed || requestId != _generationRequestId) {
        return;
      }
      _errorMessage = error.message;
      _status = TripCreationStatus.error;
    } catch (_) {
      if (_isDisposed || requestId != _generationRequestId) {
        return;
      }
      _errorMessage =
          'We could not generate the trip right now. Check your connection and try again.';
      _status = TripCreationStatus.error;
    }

    _notifyIfActive();
  }

  Future<void> retry() async {
    final request = _lastRequest;
    final idToken = _lastIdToken;
    if (request == null || idToken == null || idToken.isEmpty) {
      return;
    }
    await generateTrip(request: request, idToken: idToken);
  }

  void reset() {
    if (_isDisposed) {
      return;
    }
    _status = TripCreationStatus.idle;
    _trip = null;
    _lastRequest = null;
    _lastIdToken = null;
    _errorMessage = null;
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
    _generationRequestId++;
    super.dispose();
  }
}
