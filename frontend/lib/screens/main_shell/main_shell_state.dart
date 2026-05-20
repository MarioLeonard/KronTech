part of '../main_shell.dart';

class _MainShellState extends State<MainShell> {
  final ChatNotificationService _chatNotificationService =
      ChatNotificationService();
  final BrowserChatNotifications _browserNotifications =
      BrowserChatNotifications();

  int _selectedIndex = 0;
  final Set<int> _visitedIndexes = {0};
  bool _isSwitchingTabs = false;
  String? _initialChatConversationId;
  StreamSubscription<ChatNotificationEvent>? _notificationSubscription;
  Timer? _notificationReconnectTimer;
  OverlayEntry? _chatToastEntry;
  Timer? _chatToastTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _browserNotifications.requestPermission();
      _connectNotifications();
    });
  }

  @override
  void dispose() {
    _notificationReconnectTimer?.cancel();
    _notificationSubscription?.cancel();
    _chatToastTimer?.cancel();
    _chatToastEntry?.remove();
    _chatNotificationService.dispose();
    super.dispose();
  }

  void _connectNotifications() {
    _notificationReconnectTimer?.cancel();
    _notificationSubscription?.cancel();
    _notificationSubscription = _chatNotificationService.events.listen(
      _handleChatNotification,
    );
    _chatNotificationService.connect(
      uri: ChatApiService().notificationWebsocketUri(
        idToken: widget.user.idToken,
      ),
      onDisconnected: _scheduleNotificationReconnect,
    );
  }

  void _scheduleNotificationReconnect() {
    _notificationReconnectTimer?.cancel();
    _notificationReconnectTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _connectNotifications();
      }
    });
  }

  void _handleChatNotification(ChatNotificationEvent event) {
    if (!mounted) return;

    final senderName = event.senderName.trim().isEmpty
        ? event.senderId
        : event.senderName.trim();
    final message = event.content.trim().isEmpty
        ? 'You received a new message.'
        : event.content.trim();
    _browserNotifications.show(
      title: senderName,
      body: message,
      iconUrl: event.senderAvatarUrl,
      onClick: () => _openChatConversation(event.conversationId),
    );

    _showInAppChatToast(
      senderName: senderName,
      message: message,
      avatarUrl: event.senderAvatarUrl,
      onTap: () => _openChatConversation(event.conversationId),
    );
  }

  void _showInAppChatToast({
    required String senderName,
    required String message,
    required String? avatarUrl,
    required VoidCallback onTap,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return;
    }

    _chatToastTimer?.cancel();
    _chatToastEntry?.remove();

    _chatToastEntry = OverlayEntry(
      builder: (context) {
        return _ChatMessageToast(
          senderName: senderName,
          message: message,
          avatarUrl: avatarUrl,
          onTap: () {
            _dismissChatToast();
            onTap();
          },
          onDismiss: _dismissChatToast,
        );
      },
    );

    overlay.insert(_chatToastEntry!);
    _chatToastTimer = Timer(const Duration(seconds: 5), _dismissChatToast);
  }

  void _dismissChatToast() {
    _chatToastTimer?.cancel();
    _chatToastTimer = null;
    _chatToastEntry?.remove();
    _chatToastEntry = null;
  }

  void _openChatConversation(String conversationId) {
    if (!mounted) return;
    setState(() {
      _initialChatConversationId = conversationId;
    });
    _selectDestination(4);
  }

  Future<void> _selectDestination(int index) async {
    if (_isSwitchingTabs || index == _selectedIndex) {
      return;
    }

    _isSwitchingTabs = true;
    setState(() {
      _selectedIndex = index;
      _visitedIndexes.add(index);
    });
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (mounted) {
      _isSwitchingTabs = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      _ShellDestination(
        label: 'Home',
        icon: Icons.home_rounded,
        content: HomeScreen(
          user: widget.user,
          onNavigateToTrips: () => _selectDestination(1),
          onNavigateToChat: () => _selectDestination(4),
        ),
      ),
      const _ShellDestination(
        label: 'Trips',
        icon: Icons.route_rounded,
        content: MyTripsScreen(),
      ),
      _ShellDestination(
        label: 'Profile',
        icon: Icons.person_rounded,
        content: ProfileScreen(user: widget.user),
      ),
      const _ShellDestination(
        label: 'Friends',
        icon: Icons.group_rounded,
        content: SizedBox.shrink(),
      ),
      _ShellDestination(
        label: 'Chat',
        icon: Icons.chat_bubble_rounded,
        content: ChatScreen(initialConversationId: _initialChatConversationId),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final resolvedDestinations = [...destinations];
        resolvedDestinations[3] = _ShellDestination(
          label: 'Friends',
          icon: Icons.group_rounded,
          content: FriendsScreen(
            onOpenChat: (conversationId) {
              _openChatConversation(conversationId);
            },
          ),
        );
        resolvedDestinations[4] = _ShellDestination(
          label: 'Chat',
          icon: Icons.chat_bubble_rounded,
          content: ChatScreen(
            initialConversationId: _initialChatConversationId,
          ),
        );
        final pageContent = _ShellPageTransition(
          selectedIndex: _selectedIndex,
          children: [
            for (var index = 0; index < resolvedDestinations.length; index++)
              _visitedIndexes.contains(index)
                  ? resolvedDestinations[index].content
                  : const SizedBox.shrink(),
          ],
        );

        return PremiumBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GlassNavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          _selectDestination(index);
                        },
                        destinations: destinations,
                      ),
                      Expanded(child: pageContent),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(child: pageContent),
                      _GlassNavigationBar(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          _selectDestination(index);
                        },
                        destinations: destinations,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
