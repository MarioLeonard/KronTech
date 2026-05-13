import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/features/chat/data/browser_chat_notifications.dart';
import 'package:frontend/features/chat/data/chat_api_service.dart';
import 'package:frontend/features/chat/data/chat_notification_service.dart';
import 'package:frontend/features/trips/presentation/screens/my_trips_screen.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/screens/friends_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({required this.user, super.key});

  final AuthUser user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final ChatNotificationService _chatNotificationService =
      ChatNotificationService();
  final BrowserChatNotifications _browserNotifications =
      BrowserChatNotifications();

  int _selectedIndex = 0;
  String? _initialChatConversationId;
  StreamSubscription<ChatNotificationEvent>? _notificationSubscription;
  Timer? _notificationReconnectTimer;

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

    final title = 'New message';
    final senderName = event.senderName.trim().isEmpty
        ? event.senderId
        : event.senderName.trim();
    final body = event.content.isEmpty
        ? '$senderName: You received a new message.'
        : '$senderName: ${event.content}';
    _browserNotifications.show(
      title: title,
      body: body,
      onClick: () => _openChatConversation(event.conversationId),
    );

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(body),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () => _openChatConversation(event.conversationId),
        ),
      ),
    );
  }

  void _openChatConversation(String conversationId) {
    if (!mounted) return;
    setState(() {
      _initialChatConversationId = conversationId;
      _selectedIndex = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      _ShellDestination(
        label: 'Home',
        icon: Icons.home_rounded,
        content: HomeScreen(
          user: widget.user,
          onNavigateToTrips: () => setState(() => _selectedIndex = 1),
          onNavigateToChat: () => setState(() => _selectedIndex = 4),
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
      const _ShellDestination(
        label: 'Settings',
        icon: Icons.settings_rounded,
        content: SettingsScreen(),
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
        final current = resolvedDestinations[_selectedIndex];

        return PremiumBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: _GlassAppBar(
                title: current.label,
                onSignOut: () => context.read<AuthProvider>().signOut(),
              ),
            ),
            body: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GlassNavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          setState(() => _selectedIndex = index);
                        },
                        destinations: destinations,
                      ),
                      Expanded(child: current.content),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(child: current.content),
                      _GlassNavigationBar(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          setState(() => _selectedIndex = index);
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

class _GlassAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onSignOut;

  const _GlassAppBar({required this.title, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(title),
            actions: [
              TextButton(
                onPressed: onSignOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_ShellDestination> destinations;

  const _GlassNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: destinations.asMap().entries.map((entry) {
              final index = entry.key;
              final destination = entry.value;
              final isSelected = selectedIndex == index;

              return IconButton(
                onPressed: () => onDestinationSelected(index),
                icon: Icon(
                  destination.icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                tooltip: destination.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _GlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_ShellDestination> destinations;

  const _GlassNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: destinations.asMap().entries.map((entry) {
              final index = entry.key;
              final destination = entry.value;
              final isSelected = selectedIndex == index;

              return IconButton(
                onPressed: () => onDestinationSelected(index),
                icon: Icon(
                  destination.icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                tooltip: destination.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.content,
  });

  final String label;
  final IconData icon;
  final Widget content;
}
