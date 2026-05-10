import 'package:flutter/material.dart';
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
    return ChangeNotifierProvider.value(
      value: _savedTripsProvider,
      child: _isCreating
          ? TripCreationScreen(
              onBack: _showList,
              onTripGenerated: _showListAndRefresh,
            )
          : _MyTripsList(onAddTrip: _showCreate),
    );
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

class _MyTripsList extends StatelessWidget {
  const _MyTripsList({required this.onAddTrip});

  final VoidCallback onAddTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SavedTripsProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tripurile mele',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Itinerariile generate sunt salvate aici si pot fi sterse oricand.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: onAddTrip,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Adauga calatorie'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              switch (provider.status) {
                SavedTripsStatus.idle ||
                SavedTripsStatus.loading => const _TripsLoadingCard(),
                SavedTripsStatus.error => _TripsErrorCard(
                  message:
                      provider.errorMessage ??
                      'Nu am putut incarca tripurile salvate.',
                  onRetry: () => _reload(context),
                ),
                SavedTripsStatus.success =>
                  provider.trips.isEmpty
                      ? _TripsEmptyCard(onAddTrip: onAddTrip)
                      : _TripsGrid(trips: provider.trips),
              },
            ],
          ),
        );
      },
    );
  }

  void _reload(BuildContext context) {
    final idToken = context.read<AuthProvider>().user?.idToken;
    if (idToken == null || idToken.isEmpty) {
      return;
    }
    context.read<SavedTripsProvider>().loadTrips(idToken);
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
                    padding: const EdgeInsets.only(bottom: 12),
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
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
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

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openTripDetails(context, trip),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.route_rounded, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          _subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sterge trip',
                    onPressed: isDeleting
                        ? null
                        : () => _confirmDelete(context),
                    icon: isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (trip.summary.isNotEmpty)
                Text(
                  trip.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(trip.status)),
                  if (trip.startDate.isNotEmpty || trip.endDate.isNotEmpty)
                    Chip(label: Text('${trip.startDate} - ${trip.endDate}')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    if (trip.cities.isEmpty) {
      return 'Orase nespecificate';
    }
    return trip.cities.join(', ');
  }

  void _openTripDetails(BuildContext context, SavedTrip trip) {
    final itinerary = trip.itinerary;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
          title: const Text('Stergi tripul?'),
          content: Text('Tripul "${trip.title}" va fi sters din lista ta.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Anuleaza'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sterge'),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              trip.summary.isEmpty ? 'Detalii indisponibile.' : trip.summary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TripsLoadingCard extends StatelessWidget {
  const _TripsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 14),
            Expanded(child: Text('Se incarca tripurile salvate...')),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reincarca'),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
            Text('Nu ai tripuri salvate', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Creeaza prima calatorie si o voi salva aici automat dupa generare.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAddTrip,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Adauga calatorie'),
            ),
          ],
        ),
      ),
    );
  }
}
