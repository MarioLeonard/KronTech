import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/features/chat/data/browser_chat_notifications.dart';
import 'package:frontend/features/chat/data/chat_api_service.dart';
import 'package:frontend/features/chat/data/chat_notification_service.dart';
import 'package:frontend/features/trips/presentation/screens/my_trips_screen.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/screens/friends_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/settings_screen.dart';

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
    final theme = Theme.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
        child: Container(
          width: 112,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0B4A80).withValues(alpha: 0.46),
                const Color(0xFF063970).withValues(alpha: 0.26),
              ],
            ),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.16),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(10, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.95),
                          theme.colorScheme.tertiary.withValues(alpha: 0.9),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.28,
                          ),
                          blurRadius: 22,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: _RailDestinationList(
                      selectedIndex: selectedIndex,
                      destinations: destinations,
                      onDestinationSelected: onDestinationSelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailDestinationList extends StatelessWidget {
  static const double _buttonHeight = 68;
  static const double _itemGap = 8;
  static const double _itemExtent = _buttonHeight + _itemGap;

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_ShellDestination> destinations;

  const _RailDestinationList({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final groupHeight = destinations.length * _itemExtent;
        final groupTop = constraints.maxHeight > groupHeight
            ? (constraints.maxHeight - groupHeight) / 2
            : 0.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              top: groupTop + (selectedIndex * _itemExtent),
              left: 0,
              right: 0,
              height: _buttonHeight,
              child: const _RailSelectionPill(),
            ),
            Positioned(
              top: groupTop,
              left: 0,
              right: 0,
              child: Column(
                children: destinations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final destination = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == destinations.length - 1 ? 0 : _itemGap,
                    ),
                    child: _RailDestinationButton(
                      destination: destination,
                      isSelected: selectedIndex == index,
                      onPressed: () => onDestinationSelected(index),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RailSelectionPill extends StatelessWidget {
  const _RailSelectionPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: theme.colorScheme.tertiary,
          ),
        ),
      ),
    );
  }
}

class _RailDestinationButton extends StatelessWidget {
  final _ShellDestination destination;
  final bool isSelected;
  final VoidCallback onPressed;

  const _RailDestinationButton({
    required this.destination,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.68);

    return Tooltip(
      message: destination.label,
      waitDuration: const Duration(milliseconds: 400),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: destination.label,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: double.infinity,
              height: _RailDestinationList._buttonHeight,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  begin: inactiveColor,
                  end: isSelected ? Colors.white : inactiveColor,
                ),
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                builder: (context, color, _) {
                  return AnimatedScale(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    scale: isSelected ? 1.04 : 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(destination.icon, color: color, size: 25),
                        const SizedBox(height: 5),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          style:
                              theme.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ) ??
                              TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                          child: Text(
                            destination.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
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
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
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
