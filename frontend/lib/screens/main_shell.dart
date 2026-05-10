import 'dart:async';

import 'package:flutter/material.dart';
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
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.idToken != widget.user.idToken) {
      _connectNotifications();
    }
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

    final title = 'Mesaj nou';
    final senderName = event.senderName.trim().isEmpty
        ? event.senderId
        : event.senderName.trim();
    final body = event.content.isEmpty
        ? '$senderName: Ai primit un mesaj nou.'
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
          label: 'Deschide',
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
        content: HomeScreen(user: widget.user),
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

        return Scaffold(
          appBar: AppBar(
            title: Text(current.label),
            actions: [
              TextButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      labelType: NavigationRailLabelType.none,
                      destinations: destinations
                          .map(
                            (destination) => NavigationRailDestination(
                              icon: Icon(destination.icon),
                              label: Text(destination.label),
                            ),
                          )
                          .toList(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: current.content),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: current.content),
                    NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      destinations: destinations
                          .map(
                            (destination) => NavigationDestination(
                              icon: Icon(destination.icon),
                              label: destination.label,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
        );
      },
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
