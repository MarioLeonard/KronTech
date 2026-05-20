part of 'friends_screen.dart';

class _FriendsScreenState extends State<FriendsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTab = 0;
  int _tabDirection = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _selectTab(int index) {
    if (index == _selectedTab) {
      return;
    }

    setState(() {
      _tabDirection = index > _selectedTab ? 1 : -1;
      _selectedTab = index;
    });
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<FriendsProvider>().loadFriends();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<FriendsProvider>();

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 720;
                        final headerCopy = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FRIENDS',
                              style: theme.textTheme.labelLarge?.copyWith(
                                letterSpacing: 4,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Travel feels better together.',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 620),
                              child: Text(
                                'Find people, manage requests, and jump back into trip conversations from one clean place.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.68,
                                  ),
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
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

                        final addButton = FilledButton.icon(
                          onPressed: () => _showSearchSheet(context),
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: const Text(
                            'Find friends',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.tertiary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );

                        if (!isWide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              headerCopy,
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: addButton,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: headerCopy),
                            const SizedBox(width: 24),
                            addButton,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    _FriendsSegmentedControl(
                      selectedIndex: _selectedTab,
                      friendsCount: provider.friends.length,
                      requestsCount: provider.requests.length,
                      onChanged: _selectTab,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 360),
                          reverseDuration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                              reverseCurve: Curves.easeInCubic,
                            );
                            final offset = Tween<Offset>(
                              begin: Offset(_tabDirection * 0.08, 0),
                              end: Offset.zero,
                            ).animate(curved);

                            return FadeTransition(
                              opacity: curved,
                              child: SlideTransition(
                                position: offset,
                                child: child,
                              ),
                            );
                          },
                          child: _selectedTab == 0
                              ? _FriendsTab(
                                  key: const ValueKey('friends-tab'),
                                  scrollController: _scrollController,
                                  onOpenChat: widget.onOpenChat,
                                )
                              : const _RequestsTab(
                                  key: ValueKey('requests-tab'),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.36),
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: context.read<FriendsProvider>(),
          child: const _FindFriendsSheet(),
        );
      },
    );
  }
}
