import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/features/trips/data/backend_trip_generation_service.dart';
import 'package:frontend/features/trips/domain/saved_trip.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:frontend/features/trips/presentation/controllers/saved_trips_provider.dart';
import 'package:frontend/features/trips/presentation/screens/trip_creation_screen.dart';
import 'package:frontend/features/trips/presentation/screens/trip_details_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  late final SavedTripsProvider _savedTripsProvider;
  late final HeroController _tripsHeroController;
  late final BackendTripGenerationService _tripGenerationService;
  final GlobalKey<NavigatorState> _tripsNavigatorKey =
      GlobalKey<NavigatorState>();
  final List<_PendingTripGeneration> _pendingGenerations = [];
  String? _activeHeroTripTag;
  bool _didLoadTrips = false;

  @override
  void initState() {
    super.initState();
    _savedTripsProvider = SavedTripsProvider();
    _tripGenerationService = BackendTripGenerationService();
    _tripsHeroController = HeroController(
      createRectTween: (begin, end) {
        return MaterialRectArcTween(begin: begin, end: end);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadTrips) {
      return;
    }

    final user = context.read<AuthProvider>().user;
    final idToken = user?.idToken;
    final userId = user?.id;
    if (idToken != null &&
        idToken.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty) {
      _savedTripsProvider.loadTrips(idToken: idToken, userId: userId);
      _didLoadTrips = true;
    }
  }

  @override
  void dispose() {
    _savedTripsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _savedTripsProvider,
      child: Navigator(
        key: _tripsNavigatorKey,
        observers: [_tripsHeroController],
        onGenerateRoute: (settings) {
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) {
              return Consumer<SavedTripsProvider>(
                builder: (context, provider, child) {
                  return _TripsListView(
                    provider: provider,
                    pendingGenerations: _pendingGenerations,
                    onAddTrip: _showCreate,
                    onRetry: () => _reload(context),
                    onOpenTrip: _showTripDetails,
                    activeHeroTripTag: _activeHeroTripTag,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _reload(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final idToken = user?.idToken;
    final userId = user?.id;
    if (idToken == null ||
        idToken.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      return;
    }
    _savedTripsProvider.loadTrips(
      idToken: idToken,
      userId: userId,
      forceRefresh: true,
    );
  }

  Future<void> _showCreate() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.34),
      builder: (sheetContext) {
        return TripCreationScreen(
          onBack: () => Navigator.of(sheetContext).pop(),
          onTripGenerationRequested: _startTripGeneration,
        );
      },
    );
  }

  void _showList() {
    _tripsNavigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  Future<void> _showTripDetails(SavedTrip trip) async {
    final heroTag = _tripHeroTag(trip);
    setState(() => _activeHeroTripTag = heroTag);
    await Future<void>.delayed(const Duration(milliseconds: 16));
    if (!mounted) {
      return;
    }

    await _tripsNavigatorKey.currentState?.push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 680),
        reverseTransitionDuration: const Duration(milliseconds: 440),
        pageBuilder: (context, animation, secondaryAnimation) {
          return TripDetailsScreen(trip: trip, onBack: _showList);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    );

    if (!mounted) {
      return;
    }
    setState(() => _activeHeroTripTag = null);
  }

  Future<void> _startTripGeneration(
    TripCreationRequest request,
    String idToken,
    String userId,
  ) async {
    final pending = _PendingTripGeneration.fromRequest(request);
    setState(() => _pendingGenerations.insert(0, pending));
    unawaited(_generateTripInBackground(pending, request, idToken, userId));
  }

  Future<void> _generateTripInBackground(
    _PendingTripGeneration pending,
    TripCreationRequest request,
    String idToken,
    String userId,
  ) async {
    try {
      await _tripGenerationService.generateTrip(
        request: request,
        idToken: idToken,
      );
      if (!mounted) {
        return;
      }
      await _savedTripsProvider.loadTrips(
        idToken: idToken,
        userId: userId,
        forceRefresh: true,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _pendingGenerations.removeWhere((item) => item.id == pending.id);
      });
    } on TripGenerationException catch (error) {
      _removePendingGeneration(pending.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      _removePendingGeneration(pending.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('We could not generate the trip.')),
      );
    }
  }

  void _removePendingGeneration(String id) {
    if (!mounted) {
      return;
    }
    setState(() => _pendingGenerations.removeWhere((item) => item.id == id));
  }
}

class _TripsListView extends StatelessWidget {
  const _TripsListView({
    required this.provider,
    required this.pendingGenerations,
    required this.onAddTrip,
    required this.onRetry,
    required this.onOpenTrip,
    required this.activeHeroTripTag,
  });

  final SavedTripsProvider provider;
  final List<_PendingTripGeneration> pendingGenerations;
  final VoidCallback onAddTrip;
  final VoidCallback onRetry;
  final ValueChanged<SavedTrip> onOpenTrip;
  final String? activeHeroTripTag;

  @override
  Widget build(BuildContext context) {
    final hasTripsOrPending =
        provider.trips.isNotEmpty || pendingGenerations.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TripsHero(onAddTrip: onAddTrip),
              const SizedBox(height: 28),
              switch (provider.status) {
                SavedTripsStatus.idle || SavedTripsStatus.loading =>
                  hasTripsOrPending
                      ? _TripsSections(
                          trips: provider.trips,
                          pendingGenerations: pendingGenerations,
                          onOpenTrip: onOpenTrip,
                          activeHeroTripTag: activeHeroTripTag,
                        )
                      : const _TripsLoadingCard(),
                SavedTripsStatus.error =>
                  hasTripsOrPending
                      ? _TripsSections(
                          trips: provider.trips,
                          pendingGenerations: pendingGenerations,
                          onOpenTrip: onOpenTrip,
                          activeHeroTripTag: activeHeroTripTag,
                        )
                      : _TripsErrorCard(
                          message:
                              provider.errorMessage ??
                              'Could not load saved trips.',
                          onRetry: onRetry,
                        ),
                SavedTripsStatus.success =>
                  !hasTripsOrPending
                      ? _TripsEmptyCard(onAddTrip: onAddTrip)
                      : _TripsSections(
                          trips: provider.trips,
                          pendingGenerations: pendingGenerations,
                          onOpenTrip: onOpenTrip,
                          activeHeroTripTag: activeHeroTripTag,
                        ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _TripsHero extends StatelessWidget {
  const _TripsHero({required this.onAddTrip});

  final VoidCallback onAddTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MY TRIPS',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your generated journeys, neatly saved.',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text(
                'Create a new itinerary, revisit saved plans, and open every day-by-day route from one organized place.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 4,
              width: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: isWide ? WrapAlignment.end : WrapAlignment.start,
          children: [
            FilledButton(
              onPressed: onAddTrip,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.tertiary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Add Trip',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, const SizedBox(height: 22), actions],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: copy),
            const SizedBox(width: 24),
            actions,
          ],
        );
      },
    );
  }
}

class _TripsSections extends StatelessWidget {
  const _TripsSections({
    required this.trips,
    required this.pendingGenerations,
    required this.onOpenTrip,
    required this.activeHeroTripTag,
  });

  final List<SavedTrip> trips;
  final List<_PendingTripGeneration> pendingGenerations;
  final ValueChanged<SavedTrip> onOpenTrip;
  final String? activeHeroTripTag;

  @override
  Widget build(BuildContext context) {
    final upcoming = trips.where((trip) => !trip.isPast).toList();
    final past = trips.where((trip) => trip.isPast).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TripsSection(
          title: 'Upcoming trips',
          trips: upcoming,
          pendingGenerations: pendingGenerations,
          onOpenTrip: onOpenTrip,
          activeHeroTripTag: activeHeroTripTag,
        ),
        const SizedBox(height: 28),
        _TripsSection(
          title: 'Past trips',
          trips: past,
          pendingGenerations: const [],
          onOpenTrip: onOpenTrip,
          activeHeroTripTag: activeHeroTripTag,
        ),
      ],
    );
  }
}

class _PendingTripGeneration {
  _PendingTripGeneration({
    required this.id,
    required this.destination,
    required this.dateLabel,
    required this.subtitle,
  });

  factory _PendingTripGeneration.fromRequest(TripCreationRequest request) {
    final destination = request.cities
        .map((city) => city.trim())
        .where((city) => city.isNotEmpty)
        .join(', ');
    final safeDestination = destination.isEmpty ? 'New trip' : destination;
    final dayCount =
        request.endDate.difference(request.startDate).inDays.abs() + 1;

    return _PendingTripGeneration(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      destination: safeDestination,
      dateLabel: _formatPendingTripRange(request.startDate, request.endDate),
      subtitle:
          'Itinerary of $dayCount ${dayCount == 1 ? 'day' : 'days'} in $safeDestination',
    );
  }

  final String id;
  final String destination;
  final String dateLabel;
  final String subtitle;
}

class _TripsSection extends StatelessWidget {
  const _TripsSection({
    required this.title,
    required this.trips,
    required this.pendingGenerations,
    required this.onOpenTrip,
    required this.activeHeroTripTag,
  });

  final String title;
  final List<SavedTrip> trips;
  final List<_PendingTripGeneration> pendingGenerations;
  final ValueChanged<SavedTrip> onOpenTrip;
  final String? activeHeroTripTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemCount = trips.length + pendingGenerations.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            _CountPill(count: itemCount),
          ],
        ),
        const SizedBox(height: 12),
        if (itemCount == 0)
          _SectionEmptyState(title: title)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1080
                  ? 4
                  : constraints.maxWidth >= 760
                  ? 3
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;

              return GridView.builder(
                itemCount: itemCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: columns == 1 ? 226 : 268,
                ),
                itemBuilder: (context, index) {
                  if (index < pendingGenerations.length) {
                    return _GeneratingTripCard(
                      pending: pendingGenerations[index],
                    );
                  }
                  final trip = trips[index - pendingGenerations.length];
                  return _SavedTripCard(
                    trip: trip,
                    onOpen: onOpenTrip,
                    isHeroInFlight: activeHeroTripTag == _tripHeroTag(trip),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionEmptyState extends StatelessWidget {
  const _SectionEmptyState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        title == 'Upcoming trips'
            ? 'No upcoming trips yet.'
            : 'Past trips will appear here.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.62),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GeneratingTripCard extends StatelessWidget {
  const _GeneratingTripCard({required this.pending});

  final _PendingTripGeneration pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOutCubic,
                  builder: (context, value, child) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withValues(
                              alpha: 0.22 + value * 0.08,
                            ),
                            colorScheme.tertiary.withValues(
                              alpha: 0.18 + value * 0.08,
                            ),
                            const Color(0xFF063970),
                          ],
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x11000000),
                              Color(0x22000000),
                              Color(0xAA063970),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 34,
                              height: 34,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Generating trip...',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 14,
                        child: Text(
                          pending.destination,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        const Color(0xFF0E5A90).withValues(alpha: 0.18),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pending.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.74),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Preparing places, schedule, stays, restaurants, and estimates.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.58),
                          height: 1.3,
                        ),
                      ),
                      const Spacer(),
                      _buildPendingChip(pending.dateLabel),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SavedTripCard extends StatelessWidget {
  const _SavedTripCard({
    required this.trip,
    required this.onOpen,
    required this.isHeroInFlight,
  });

  final SavedTrip trip;
  final ValueChanged<SavedTrip> onOpen;
  final bool isHeroInFlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SavedTripsProvider>();
    final isDeleting = provider.deletingTripId == trip.id;
    final destination = trip.destinationLabel;
    final description = trip.compactDescription;
    final dateLabel = trip.formattedDateRange;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        child: InkWell(
          onTap: () => onOpen(trip),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: _tripHeroTag(trip),
                        flightShuttleBuilder:
                            (
                              flightContext,
                              animation,
                              flightDirection,
                              fromHeroContext,
                              toHeroContext,
                            ) {
                              return _RoundedHeroFlight(
                                animation: animation,
                                child: _TripPreviewImage(
                                  url:
                                      trip.itinerary?.destinationImageUrl ?? '',
                                ),
                              );
                            },
                        child: _TripPreviewImage(
                          url: trip.itinerary?.destinationImageUrl ?? '',
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isHeroInFlight ? 0 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x22063970),
                                Color(0x11063970),
                                Color(0xCC063970),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isHeroInFlight ? 0 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              left: 16,
                              right: 54,
                              bottom: 14,
                              child: Text(
                                destination,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF063970,
                                  ).withValues(alpha: 0.58),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Delete trip',
                                  onPressed: isDeleting
                                      ? null
                                      : () => _confirmDelete(context),
                                  icon: isDeleting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          const Color(0xFF0E5A90).withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.66),
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                        _buildChip(context, dateLabel),
                      ],
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

  Widget _buildChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF063970),
          title: const Text(
            'Delete trip?',
            style: TextStyle(color: Colors.white),
          ), // 2. Translate Text
          content: Text(
            'Trip "${trip.title}" will be deleted from your list.', // 2. Translate Text
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ), // 2. Translate Text
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ), // 2. Translate Text
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final idToken = context.read<AuthProvider>().user?.idToken;
    if (idToken == null || idToken.isEmpty) {
      return;
    }

    await context.read<SavedTripsProvider>().deleteTrip(
      idToken: idToken,
      tripId: trip.id,
    );
  }
}

String _tripHeroTag(SavedTrip trip) {
  return 'trip-image-${trip.id.isEmpty ? trip.title : trip.id}';
}

class _TripPreviewImage extends StatelessWidget {
  const _TripPreviewImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (url.isEmpty) {
      return _TripPreviewFallback(colorScheme: colorScheme);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _TripPreviewFallback(colorScheme: colorScheme);
      },
    );
  }
}

class _TripPreviewFallback extends StatelessWidget {
  const _TripPreviewFallback({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.34),
            colorScheme.tertiary.withValues(alpha: 0.24),
            const Color(0xFF063970),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.travel_explore_rounded,
          color: Colors.white,
          size: 54,
        ),
      ),
    );
  }
}

class _RoundedHeroFlight extends StatelessWidget {
  const _RoundedHeroFlight({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final radius = Tween<double>(
          begin: 18,
          end: 28,
        ).transform(Curves.easeInOutCubic.transform(animation.value));

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child,
        );
      },
      child: child,
    );
  }
}

extension _SavedTripDisplay on SavedTrip {
  bool get isPast {
    final parsedEndDate = DateTime.tryParse(endDate);
    if (parsedEndDate == null) {
      return false;
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return parsedEndDate.isBefore(todayDate);
  }

  String get destinationLabel {
    if (cities.isNotEmpty) {
      return cities.first;
    }
    final itineraryCities = itinerary?.cities ?? const [];
    if (itineraryCities.isNotEmpty) {
      return itineraryCities.first;
    }
    return title;
  }

  String get compactDescription {
    final dayCount = itinerary?.days.length ?? 0;
    final destination = destinationLabel;
    if (dayCount > 0) {
      return 'Itinerary of $dayCount ${dayCount == 1 ? 'day' : 'days'} in $destination';
    }
    if (summary.isNotEmpty) {
      return summary;
    }
    return 'Saved itinerary in $destination';
  }

  String get formattedDateRange {
    final parsedDate = DateTime.tryParse(startDate);
    if (parsedDate == null) {
      return startDate.isEmpty ? 'Date TBC' : startDate;
    }
    final parsedEndDate = DateTime.tryParse(endDate);
    if (parsedEndDate == null || _isSameDay(parsedDate, parsedEndDate)) {
      return _formatTripDate(parsedDate);
    }
    if (parsedDate.year == parsedEndDate.year) {
      return '${parsedDate.day} ${_monthAbbreviation(parsedDate.month)} - ${parsedEndDate.day} ${_monthAbbreviation(parsedEndDate.month)} ${parsedEndDate.year}';
    }
    return '${_formatTripDate(parsedDate)} - ${_formatTripDate(parsedEndDate)}';
  }
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatTripDate(DateTime date) {
  return '${date.day} ${_monthAbbreviation(date.month)} ${date.year}';
}

String _formatPendingTripRange(DateTime startDate, DateTime endDate) {
  if (_isSameDay(startDate, endDate)) {
    return _formatTripDate(startDate);
  }
  if (startDate.year == endDate.year) {
    return '${startDate.day} ${_monthAbbreviation(startDate.month)} - ${endDate.day} ${_monthAbbreviation(endDate.month)} ${endDate.year}';
  }
  return '${_formatTripDate(startDate)} - ${_formatTripDate(endDate)}';
}

String _monthAbbreviation(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > months.length) {
    return '';
  }
  return months[month - 1];
}

class _TripsLoadingCard extends StatelessWidget {
  const _TripsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      color: Colors.white,
      opacity: 0.05,
      blur: 12,
      borderRadius: 24,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                'Loading saved trips...', // 2. Translate Text
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripsErrorCard extends StatelessWidget {
  const _TripsErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      color: Colors.white,
      opacity: 0.05,
      blur: 12,
      borderRadius: 24,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'), // 2. Translate Text
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripsEmptyCard extends StatelessWidget {
  const _TripsEmptyCard({required this.onAddTrip});

  final VoidCallback onAddTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 3. Apply Glassmorphism to the Empty State Card
    return GlassContainer(
      color: Colors.white,
      opacity: 0.05,
      blur: 12.0,
      borderRadius: 24,
      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.travel_explore_rounded,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No saved trips', // 2. Translate Text
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first journey and we will automatically save it here.', // 2. Translate Text
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAddTrip,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Trip'), // 2. Translate Text
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
