part of '../home_screen.dart';

class _HomeScreenState extends State<HomeScreen> {
  static const int _sectionCount = 4;
  static const Duration _scrollGestureLock = Duration(milliseconds: 1400);

  late final PageController _pageController;
  int _selectedSection = 0;
  bool _isPaging = false;
  DateTime _ignoreScrollUntil = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToSection(int index) async {
    if (_isPaging || index == _selectedSection) {
      return;
    }

    final nextIndex = index.clamp(0, _sectionCount - 1);
    if (nextIndex == _selectedSection) {
      return;
    }

    _isPaging = true;
    _ignoreScrollUntil = DateTime.now().add(_scrollGestureLock);
    await _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeInOutCubicEmphasized,
    );
    if (mounted) {
      setState(() => _selectedSection = nextIndex);
    }
    _isPaging = false;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        _isPaging ||
        DateTime.now().isBefore(_ignoreScrollUntil)) {
      return;
    }

    if (event.scrollDelta.dy > 0) {
      _goToSection(_selectedSection + 1);
    } else if (event.scrollDelta.dy < 0) {
      _goToSection(_selectedSection - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _AnimatedFeatureSection(
            isActive: _selectedSection == 0,
            child: _WelcomeLandingPage(
              eyebrow: 'Welcome',
              title:
                  'Hi ${widget.user.displayName?.split(' ').first ?? 'Traveler'}, ready to plan?',
              subtitle:
                  'Plan smarter city breaks, routes, and conversations in one place',
              imageCard: FeatureCard(
                title: 'KronTech',
                buttonText: 'Explore the app',
                icon: Icons.travel_explore_rounded,
                imagePath: 'assets/images/landing_travel.jpg',
                buttonIcon: Icons.arrow_downward_rounded,
                onPressed: () => _goToSection(1),
              ),
              onPrimaryPressed: () => _goToSection(1),
            ),
          ),
          _AnimatedFeatureSection(
            isActive: _selectedSection == 1,
            child: _HomeFeaturePage(
              isCardLeft: true,
              card: FeatureCard(
                title: 'Trips',
                buttonText: 'Add Trip',
                icon: Icons.explore_rounded,
                imagePath: 'assets/images/trips.png',
                onPressed: widget.onNavigateToTrips,
              ),
              textContent: _buildMarketingText(
                context,
                eyebrow: 'Best Routes',
                title: 'Find the good parts of every city',
                subtitle:
                    'Build interesting routes for the places you are about to visit, then keep the plan easy to scan',
              ),
            ),
          ),
          _AnimatedFeatureSection(
            isActive: _selectedSection == 2,
            child: _HomeFeaturePage(
              isCardLeft: false,
              card: FeatureCard(
                title: 'Messages',
                buttonText: 'Open Chat',
                icon: Icons.chat_bubble_rounded,
                imagePath: 'assets/images/messages.png',
                onPressed: widget.onNavigateToChat,
              ),
              textContent: _buildMarketingText(
                context,
                eyebrow: 'Stay Connected',
                title: 'Keep your friends close',
                subtitle:
                    'Add the people you travel with and keep the conversation next to the trip',
              ),
            ),
          ),
          _AnimatedFeatureSection(
            isActive: _selectedSection == 3,
            child: _AppStoryPage(onPrimaryPressed: widget.onNavigateToTrips),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingText(
    BuildContext context, {
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.68),
            fontWeight: FontWeight.w500,
            height: 1.45,
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
  }
}
