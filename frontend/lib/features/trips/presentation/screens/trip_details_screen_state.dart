part of 'trip_details_screen.dart';

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final Map<int, TextEditingController> _dayPlanControllers = {};
  late SavedTrip _trip;
  int _selectedSection = 0;

  GeneratedTrip? get _itinerary => _trip.itinerary;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    final days = _itinerary?.days ?? const <TripDay>[];
    for (final day in days) {
      _dayPlanControllers[day.dayNumber] = TextEditingController(
        text: _editablePlanFor(day),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _dayPlanControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itinerary = _itinerary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 680 ? 16.0 : 32.0;

        return _AdaptiveDetailsScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailsHero(
                    trip: _trip,
                    itinerary: itinerary,
                    onBack:
                        widget.onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  _AfterHeroSettledFade(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 22),
                        _SectionToggles(
                          selectedIndex: _selectedSection,
                          onSelected: (index) {
                            setState(() => _selectedSection = index);
                          },
                        ),
                        const SizedBox(height: 20),
                        _DetailsSectionSwitcher(
                          sectionKey: _selectedSection,
                          child: _buildSelectedSection(context, itinerary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedSection(BuildContext context, GeneratedTrip? itinerary) {
    if (itinerary == null && _selectedSection != 1) {
      return _DetailPanel(
        icon: Icons.travel_explore_rounded,
        title: 'Trip details',
        subtitle: 'Saved trip overview',
        child: Text(
          _trip.summary.isEmpty
              ? 'Details are unavailable for this saved trip.'
              : _trip.summary,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.76),
            height: 1.6,
          ),
        ),
      );
    }

    if (_selectedSection == 1) {
      return _TripFriendsSection(
        trip: _trip,
        onAddFriend: _addTripFriend,
        onRemoveFriend: _removeTripFriend,
      );
    }

    if (itinerary == null) {
      return _DetailPanel(
        icon: Icons.group_rounded,
        title: 'Friends',
        subtitle: 'People added to this trip',
        child: const _EmptySection(message: 'Trip details are unavailable.'),
      );
    }

    return switch (_selectedSection) {
      0 => _OverviewSection(trip: _trip, itinerary: itinerary),
      2 => _AccommodationSection(itinerary: itinerary),
      3 => _PlacesSection(
        itinerary: itinerary,
        onVisitedChanged: _updatePlaceVisited,
      ),
      4 => _EditableScheduleSection(
        itinerary: itinerary,
        controllers: _dayPlanControllers,
      ),
      5 => _RestaurantsSection(itinerary: itinerary),
      _ => _NotesSection(itinerary: itinerary),
    };
  }

  void _updatePlaceVisited(_PlaceItem place, bool isVisited) {
    final user = context.read<AuthProvider>().user;
    final idToken = user?.idToken;
    final userId = user?.id;
    if (idToken == null ||
        idToken.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      return;
    }

    final updatedTrip = context.read<SavedTripsProvider>().updatePlaceVisited(
      tripId: _trip.id,
      dayNumber: place.dayNumber,
      activityIndex: place.activityIndex,
      isVisited: isVisited,
      idToken: idToken,
      userId: userId,
    );
    if (updatedTrip != null && mounted) {
      setState(() => _trip = updatedTrip);
    }
  }

  Future<bool> _addTripFriend(FriendUser friend) async {
    final user = context.read<AuthProvider>().user;
    final updatedTrip = await context.read<SavedTripsProvider>().addTripFriend(
      tripId: _trip.id,
      friendId: friend.id,
      idToken: user?.idToken ?? '',
      userId: user?.id ?? '',
    );
    if (updatedTrip != null && mounted) {
      setState(() => _trip = updatedTrip);
      return true;
    }
    return false;
  }

  Future<void> _removeTripFriend(FriendUser friend) async {
    final user = context.read<AuthProvider>().user;
    final updatedTrip = await context
        .read<SavedTripsProvider>()
        .removeTripFriend(
          tripId: _trip.id,
          friendId: friend.id,
          idToken: user?.idToken ?? '',
          userId: user?.id ?? '',
        );
    if (updatedTrip != null && mounted) {
      setState(() => _trip = updatedTrip);
    }
  }
}
