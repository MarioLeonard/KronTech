part of 'trip_creation_screen.dart';

class _TripCreationView extends StatelessWidget {
  _TripCreationView({this.onBack, this.onTripGenerationRequested})
    : _savedTripsService = BackendSavedTripsService();

  final VoidCallback? onBack;
  final TripGenerationRequestHandler? onTripGenerationRequested;
  final BackendSavedTripsService _savedTripsService;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        final form = TripRequestForm(
          isLoading: false,
          onClose: onBack,
          onSubmit: (request) => _generate(context, request),
          onReset: () {},
        );

        return SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: form,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _generate(
    BuildContext context,
    TripCreationRequest request,
  ) async {
    final user = context.read<AuthProvider>().user;
    final idToken = user?.idToken;
    final userId = user?.id;
    if (idToken == null || idToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session expired. Please sign in again.'),
        ),
      );
      return;
    }
    if (userId == null || userId.isEmpty) {
      return;
    }

    final hasReachedLimit = await _hasReachedDailyGenerationLimit(
      idToken: idToken,
      userId: userId,
    );
    if (!context.mounted) {
      return;
    }
    if (hasReachedLimit) {
      await _showTripGenerationPaywall(context);
      return;
    }

    await _markTripGeneratedToday(userId);
    await onTripGenerationRequested?.call(request, idToken, userId);
    if (!context.mounted) {
      return;
    }
    onBack?.call();
  }

  Future<bool> _hasReachedDailyGenerationLimit({
    required String idToken,
    required String userId,
  }) async {
    final todayKey = _todayKey();
    final box = HiveService.getSavedTripsBox();
    final limitKey = _generationLimitKey(userId);
    if (box.get(limitKey) == todayKey) {
      return true;
    }

    if (_hasTripCreatedTodayInCache(userId: userId, todayKey: todayKey)) {
      await _markTripGeneratedToday(userId);
      return true;
    }

    try {
      final remoteTrips = await _savedTripsService.fetchTrips(
        idToken: idToken,
        userId: userId,
        forceRefresh: true,
      );
      final hasRemoteTripToday = remoteTrips.any((trip) {
        final createdAt = DateTime.tryParse(trip.createdAt);
        if (createdAt == null) {
          return false;
        }
        return _dateKey(createdAt.toLocal()) == todayKey;
      });
      if (hasRemoteTripToday) {
        await _markTripGeneratedToday(userId);
      }
      return hasRemoteTripToday;
    } on SavedTripsException {
      return _hasTripCreatedTodayInCache(userId: userId, todayKey: todayKey);
    }
  }

  bool _hasTripCreatedTodayInCache({
    required String userId,
    required String todayKey,
  }) {
    final cached = HiveService.getSavedTripsBox().get('saved_trips_$userId');
    if (cached is! Map) {
      return false;
    }
    final trips = cached['trips'];
    if (trips is! List) {
      return false;
    }
    return trips.whereType<Map>().any((trip) {
      final createdAt = trip['createdAt'];
      if (createdAt is! String || createdAt.isEmpty) {
        return false;
      }
      final parsed = DateTime.tryParse(createdAt);
      if (parsed == null) {
        return false;
      }
      return _dateKey(parsed.toLocal()) == todayKey;
    });
  }

  Future<void> _markTripGeneratedToday(String userId) async {
    await HiveService.getSavedTripsBox().put(
      _generationLimitKey(userId),
      _todayKey(),
    );
  }

  String _generationLimitKey(String userId) {
    return 'trip_generation_limit_$userId';
  }

  String _todayKey() {
    return _dateKey(DateTime.now());
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _showTripGenerationPaywall(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const _TripGenerationPaywallDialog(),
    );
  }
}
