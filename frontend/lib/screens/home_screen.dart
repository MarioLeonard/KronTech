import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/feature_card.dart';
import 'package:frontend/components/feature_row.dart';
import 'package:frontend/models/auth_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.user,
    required this.onNavigateToTrips,
    required this.onNavigateToChat,
    super.key,
  });

  final AuthUser user;
  final VoidCallback onNavigateToTrips;
  final VoidCallback onNavigateToChat;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

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

class _WelcomeLandingPage extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final FeatureCard imageCard;
  final VoidCallback onPrimaryPressed;

  const _WelcomeLandingPage({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.imageCard,
    required this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;

              final textContent = Column(
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

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    textContent,
                    const SizedBox(height: 28),
                    imageCard,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: textContent),
                  const SizedBox(width: 52),
                  Expanded(flex: 5, child: Center(child: imageCard)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AppStoryPage extends StatelessWidget {
  final VoidCallback onPrimaryPressed;

  const _AppStoryPage({required this.onPrimaryPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'From idea to itinerary, without losing the group chat.',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: const [
                  _StoryPoint(
                    icon: Icons.route_rounded,
                    title: 'Route-first planning',
                    text: 'Turn destination ideas into days that make sense.',
                  ),
                  _StoryPoint(
                    icon: Icons.forum_rounded,
                    title: 'Built for friends',
                    text: 'Keep travel decisions close to the people joining.',
                  ),
                  _StoryPoint(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Less decision fatigue',
                    text: 'Focus on the trip instead of juggling tabs.',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: FilledButton.icon(
                  onPressed: onPrimaryPressed,
                  icon: const Icon(Icons.explore_rounded, size: 20),
                  label: const Text(
                    'Start with a trip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _StoryPoint({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.62),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFeaturePage extends StatelessWidget {
  final FeatureCard card;
  final Widget textContent;
  final bool isCardLeft;

  const _HomeFeaturePage({
    required this.card,
    required this.textContent,
    required this.isCardLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: FeatureRow(
            isCardLeft: isCardLeft,
            card: card,
            textContent: textContent,
          ),
        ),
      ),
    );
  }
}

class _AnimatedFeatureSection extends StatefulWidget {
  final bool isActive;
  final Widget child;

  const _AnimatedFeatureSection({required this.isActive, required this.child});

  @override
  State<_AnimatedFeatureSection> createState() =>
      _AnimatedFeatureSectionState();
}

class _AnimatedFeatureSectionState extends State<_AnimatedFeatureSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _opacity = Tween<double>(
      begin: 0.78,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedFeatureSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
