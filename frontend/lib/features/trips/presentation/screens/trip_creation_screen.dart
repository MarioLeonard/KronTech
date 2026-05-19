import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/features/trips/data/backend_saved_trips_service.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_request_form.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/utils/hive_service.dart';
import 'package:provider/provider.dart';

typedef TripGenerationRequestHandler =
    Future<void> Function(
      TripCreationRequest request,
      String idToken,
      String userId,
    );

class TripCreationScreen extends StatelessWidget {
  const TripCreationScreen({
    super.key,
    this.onBack,
    this.onTripGenerationRequested,
  });

  final VoidCallback? onBack;
  final TripGenerationRequestHandler? onTripGenerationRequested;

  @override
  Widget build(BuildContext context) {
    return _TripCreationView(
      onBack: onBack,
      onTripGenerationRequested: onTripGenerationRequested,
    );
  }
}

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

class _TripGenerationPaywallDialog extends StatelessWidget {
  const _TripGenerationPaywallDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: GlassContainer(
          color: const Color(0xFF0E5A90),
          opacity: 0.28,
          blur: 18,
          borderRadius: 26,
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.tertiary.withValues(
                              alpha: 0.26,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        'Daily limit reached',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'You can generate one trip per day on the free plan. Upgrade to unlock more AI itineraries whenever you need them.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _PaywallFeature(label: 'Unlimited trip generation'),
                    _PaywallFeature(label: 'More itinerary experiments'),
                    _PaywallFeature(label: 'Premium planning flow'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payments are coming soon.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text(
                      'Upgrade to Pro',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.tertiary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Maybe tomorrow',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaywallFeature extends StatelessWidget {
  const _PaywallFeature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
