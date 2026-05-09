import 'package:flutter/foundation.dart';
import 'package:frontend/features/trips/data/gemini_trip_service.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';

enum TripCreationStatus { idle, loading, success, error }

class TripCreationProvider extends ChangeNotifier {
  TripCreationProvider({GeminiTripService? tripService})
    : _tripService = tripService ?? GeminiTripService();

  final GeminiTripService _tripService;

  TripCreationStatus _status = TripCreationStatus.idle;
  GeneratedTrip? _trip;
  TripCreationRequest? _lastRequest;
  String? _errorMessage;

  TripCreationStatus get status => _status;
  GeneratedTrip? get trip => _trip;
  TripCreationRequest? get lastRequest => _lastRequest;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TripCreationStatus.loading;

  Future<void> generateTrip(TripCreationRequest request) async {
    _status = TripCreationStatus.loading;
    _lastRequest = request;
    _errorMessage = null;
    notifyListeners();

    try {
      final generatedTrip = await _tripService.generateTrip(request);
      _trip = generatedTrip;
      _status = TripCreationStatus.success;
    } on GeminiTripException catch (error) {
      _errorMessage = error.message;
      _status = TripCreationStatus.error;
    } catch (_) {
      _errorMessage =
          'Nu am putut genera excursia acum. Verifica conexiunea si incearca din nou.';
      _status = TripCreationStatus.error;
    }

    notifyListeners();
  }

  Future<void> retry() async {
    final request = _lastRequest;
    if (request == null) {
      return;
    }
    await generateTrip(request);
  }

  void reset() {
    _status = TripCreationStatus.idle;
    _trip = null;
    _lastRequest = null;
    _errorMessage = null;
    notifyListeners();
  }
}
