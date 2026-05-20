part of 'my_trips_screen.dart';

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
