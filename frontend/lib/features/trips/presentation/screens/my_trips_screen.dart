import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/features/trips/domain/saved_trip.dart';
import 'package:frontend/features/trips/presentation/controllers/saved_trips_provider.dart';
import 'package:frontend/features/trips/presentation/screens/trip_creation_screen.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_result_view.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  late final SavedTripsProvider _savedTripsProvider;
  bool _isCreating = false;
  bool _didLoadTrips = false;

  @override
  void initState() {
    super.initState();
    _savedTripsProvider = SavedTripsProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadTrips) {
      return;
    }

    final idToken = context.read<AuthProvider>().user?.idToken;
    if (idToken != null && idToken.isNotEmpty) {
      _savedTripsProvider.loadTrips(idToken);
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
    if (_isCreating) {
      return TripCreationScreen(
        onBack: _showList,
        onTripGenerated: _showListAndRefresh,
      );
    }

    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _savedTripsProvider,
      child: Consumer<SavedTripsProvider>(
        builder: (context, provider, child) {
          return Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Trips',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _showCreate,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Add Trip'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      'Generated itineraries are saved here and can be deleted anytime.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Main Content
                    switch (provider.status) {
                      SavedTripsStatus.idle ||
                      SavedTripsStatus.loading => const _TripsLoadingCard(),
                      SavedTripsStatus.error => _TripsErrorCard(
                        message:
                            provider.errorMessage ??
                            'Could not load saved trips.',
                        onRetry: () => _reload(context),
                      ),
                      SavedTripsStatus.success =>
                        provider.trips.isEmpty
                            ? _TripsEmptyCard(onAddTrip: _showCreate)
                            : _TripsGrid(trips: provider.trips),
                    },
                  ],
                ), // Closes Column
              ), // Closes Padding
            ), // Closes SingleChildScrollView
          ); // Closes Align (THIS WAS THE MISSING ONE!)
        },
      ),
    );
  }

  void _reload(BuildContext context) {
    final idToken = context.read<AuthProvider>().user?.idToken;
    if (idToken == null || idToken.isEmpty) {
      return;
    }
    _savedTripsProvider.loadTrips(idToken);
  }

  void _showCreate() {
    setState(() => _isCreating = true);
  }

  void _showList() {
    setState(() => _isCreating = false);
  }

  void _showListAndRefresh() {
    setState(() => _isCreating = false);
    final idToken = context.read<AuthProvider>().user?.idToken;
    if (idToken == null || idToken.isEmpty) {
      return;
    }
    _savedTripsProvider.loadTrips(idToken);
  }
}

class _TripsGrid extends StatelessWidget {
  const _TripsGrid({required this.trips});

  final List<SavedTrip> trips;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        if (!isWide) {
          return Column(
            children: trips
                .map(
                  (trip) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SavedTripCard(trip: trip),
                  ),
                )
                .toList(),
          );
        }

        return GridView.builder(
          itemCount: trips.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) => _SavedTripCard(trip: trips[index]),
        );
      },
    );
  }
}

class _SavedTripCard extends StatelessWidget {
  const _SavedTripCard({required this.trip});

  final SavedTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SavedTripsProvider>();
    final isDeleting = provider.deletingTripId == trip.id;

    // Upgrading to GlassContainer for consistent premium look
    return GlassContainer(
      color: Colors.white,
      opacity: 0.05,
      blur: 12,
      borderRadius: 24,
      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openTripDetails(context, trip),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.route_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete trip', // 2. Translate Text
                    onPressed: isDeleting
                        ? null
                        : () => _confirmDelete(context),
                    icon: isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (trip.summary.isNotEmpty)
                Text(
                  trip.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(context, trip.status),
                  if (trip.startDate.isNotEmpty || trip.endDate.isNotEmpty)
                    _buildChip(context, '${trip.startDate} - ${trip.endDate}'),
                ],
              ),
            ],
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

  String get _subtitle {
    if (trip.cities.isEmpty) {
      return 'No cities specified'; // 2. Translate Text
    }
    return trip.cities.join(', ');
  }

  void _openTripDetails(BuildContext context, SavedTrip trip) {
    final itinerary = trip.itinerary;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF063970),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: itinerary == null
                  ? _MissingItineraryDetails(trip: trip)
                  : TripResultView(trip: itinerary),
            );
          },
        );
      },
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

class _MissingItineraryDetails extends StatelessWidget {
  const _MissingItineraryDetails({required this.trip});

  final SavedTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trip.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          trip.summary.isEmpty
              ? 'Details unavailable.'
              : trip.summary, // 2. Translate Text
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
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
