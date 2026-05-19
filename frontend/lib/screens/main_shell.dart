import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
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

class _ShellPageTransition extends StatefulWidget {
  const _ShellPageTransition({
    required this.selectedIndex,
    required this.children,
  });

  final int selectedIndex;
  final List<Widget> children;

  @override
  State<_ShellPageTransition> createState() => _ShellPageTransitionState();
}

class _ShellPageTransitionState extends State<_ShellPageTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _currentIndex = 0;
  int? _previousIndex;
  bool _incomingFromBottom = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..value = 1;
  }

  @override
  void didUpdateWidget(covariant _ShellPageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == oldWidget.selectedIndex) {
      return;
    }

    _previousIndex = _currentIndex;
    _incomingFromBottom = widget.selectedIndex > _currentIndex;
    _currentIndex = widget.selectedIndex;
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) {
        setState(() => _previousIndex = null);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );

    return ClipRect(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value;
          final direction = _incomingFromBottom ? 1.0 : -1.0;
          final outgoingOffset = Offset(0, -direction * progress);
          final incomingOffset = Offset(0, direction * (1 - progress));

          return Stack(
            fit: StackFit.expand,
            children: [
              for (var index = 0; index < widget.children.length; index++)
                _ShellPageSlot(
                  key: ValueKey('shell-page-$index'),
                  isVisible: index == _currentIndex || index == _previousIndex,
                  isActive: index == _currentIndex,
                  offset: index == _currentIndex
                      ? incomingOffset
                      : index == _previousIndex
                      ? outgoingOffset
                      : Offset.zero,
                  child: widget.children[index],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ShellPageSlot extends StatelessWidget {
  const _ShellPageSlot({
    required this.isVisible,
    required this.isActive,
    required this.offset,
    required this.child,
    super.key,
  });

  final bool isVisible;
  final bool isActive;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final page = TickerMode(
      enabled: isVisible,
      child: IgnorePointer(
        ignoring: !isActive,
        child: RepaintBoundary(
          child: FractionalTranslation(translation: offset, child: child),
        ),
      ),
    );

    if (isVisible) {
      return page;
    }

    return Offstage(offstage: true, child: page);
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
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
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

              return _BottomDestinationButton(
                destination: destination,
                isSelected: isSelected,
                onPressed: () => onDestinationSelected(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ChatMessageToast extends StatelessWidget {
  const _ChatMessageToast({
    required this.senderName,
    required this.message,
    required this.avatarUrl,
    required this.onTap,
    required this.onDismiss,
  });

  final String senderName;
  final String message;
  final String? avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 560;

    return Positioned(
      right: isCompact ? 14 : 24,
      bottom: isCompact ? 96 : 24,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              return Opacity(
                opacity: progress,
                child: Transform.translate(
                  offset: Offset(22 * (1 - progress), 10 * (1 - progress)),
                  child: Transform.scale(
                    alignment: Alignment.bottomRight,
                    scale: 0.96 + (0.04 * progress),
                    child: child,
                  ),
                ),
              );
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isCompact ? width - 28 : 380,
                minWidth: isCompact ? width - 28 : 340,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF071827).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.32),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        AppAvatar(imageUrl: avatarUrl, radius: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.76),
                                fontWeight: FontWeight.w700,
                                height: 1.32,
                              ),
                              children: [
                                TextSpan(
                                  text: '$senderName: ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(text: message),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Dismiss',
                          onPressed: onDismiss,
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomDestinationButton extends StatelessWidget {
  const _BottomDestinationButton({
    required this.destination,
    required this.isSelected,
    required this.onPressed,
  });

  final _ShellDestination destination;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Tooltip(
      message: destination.label,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: destination.label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: SizedBox(
              width: 52,
              height: 52,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                scale: isSelected ? 1.08 : 1,
                child: Icon(destination.icon, color: color),
              ),
            ),
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
