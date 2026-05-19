import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/features/friends/domain/friend_request.dart';
import 'package:frontend/features/friends/domain/friend_user.dart';
import 'package:frontend/features/friends/presentation/controllers/friends_provider.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({this.onOpenChat, super.key});

  final ValueChanged<String>? onOpenChat;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

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

class _FriendsSegmentedControl extends StatelessWidget {
  const _FriendsSegmentedControl({
    required this.selectedIndex,
    required this.friendsCount,
    required this.requestsCount,
    required this.onChanged,
  });

  final int selectedIndex;
  final int friendsCount;
  final int requestsCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      color: const Color(0xFF0E5A90),
      opacity: 0.18,
      blur: 18,
      borderRadius: 26,
      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final indicatorWidth = constraints.maxWidth / 2;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * indicatorWidth,
                  top: 0,
                  bottom: 0,
                  width: indicatorWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _FriendsSegmentButton(
                        label: 'Friends',
                        count: friendsCount,
                        icon: Icons.group_rounded,
                        selected: selectedIndex == 0,
                        onTap: () => onChanged(0),
                      ),
                    ),
                    Expanded(
                      child: _FriendsSegmentButton(
                        label: 'Requests',
                        count: requestsCount,
                        icon: Icons.mark_email_unread_rounded,
                        selected: selectedIndex == 1,
                        onTap: () => onChanged(1),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FriendsSegmentButton extends StatelessWidget {
  const _FriendsSegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.count = 0,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      style:
          theme.textTheme.labelLarge?.copyWith(
            color: Colors.white.withValues(alpha: selected ? 0.96 : 0.62),
            fontWeight: FontWeight.w900,
          ) ??
          TextStyle(
            color: Colors.white.withValues(alpha: selected ? 0.96 : 0.62),
            fontWeight: FontWeight.w900,
          ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? colorScheme.primary
                    : Colors.white.withValues(alpha: 0.62),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                _CountBadge(count: count),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  const _FriendsTab({
    required this.scrollController,
    this.onOpenChat,
    super.key,
  });

  final ScrollController scrollController;
  final ValueChanged<String>? onOpenChat;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();

    if (provider.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.friends.isEmpty) {
      return _StateCard(
        icon: Icons.error_outline_rounded,
        title: 'We could not load friends',
        message: provider.errorMessage!,
        actionLabel: 'Try again',
        onAction: () => provider.loadFriends(refresh: true),
      );
    }

    if (provider.friends.isEmpty) {
      return const _StateCard(
        icon: Icons.group_outlined,
        title: 'You do not have friends yet',
        message: 'Search for people in the app and send the first request.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadFriends(refresh: true),
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 24),
        itemCount: provider.friends.length + (provider.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= provider.friends.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final friend = provider.friends[index];
          return _PersonTile(
            user: friend,
            trailing: _FriendActions(
              friend: friend,
              onOpenChat: friend.conversationId == null || onOpenChat == null
                  ? null
                  : () => onOpenChat!(friend.conversationId!),
            ),
          );
        },
      ),
    );
  }
}

class _FriendActions extends StatelessWidget {
  const _FriendActions({required this.friend, this.onOpenChat});

  final FriendUser friend;
  final VoidCallback? onOpenChat;

  Future<void> _removeFriend(BuildContext context) async {
    final provider = context.read<FriendsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF063970),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Remove friend?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          content: Text(
            'You will remove ${friend.name} from your friends list.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Remove',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final removed = await provider.removeFriend(friend);
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          removed
              ? '${friend.name} was removed from friends.'
              : provider.errorMessage ?? 'We could not remove this friend.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<FriendsProvider>();
    final isLoading = provider.isActionLoading(friend.id);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChatActionButton(onPressed: isLoading ? null : onOpenChat),
        const SizedBox(width: 6),
        PopupMenuButton<_FriendMenuAction>(
          tooltip: 'More',
          enabled: !isLoading,
          color: const Color(0xFF063970),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          icon: Icon(
            Icons.more_horiz_rounded,
            color: Colors.white.withValues(alpha: 0.74),
          ),
          onSelected: (action) {
            if (action == _FriendMenuAction.remove) {
              _removeFriend(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _FriendMenuAction.remove,
              child: Row(
                children: [
                  Icon(
                    Icons.person_remove_alt_1_rounded,
                    color: theme.colorScheme.error,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Remove friend',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _FriendMenuAction { remove }

class _ChatActionButton extends StatelessWidget {
  const _ChatActionButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Chat',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: onPressed == null ? 0.42 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.28),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.chat_bubble_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();

    if (provider.isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.requestsErrorMessage != null && provider.requests.isEmpty) {
      return _StateCard(
        icon: Icons.error_outline_rounded,
        title: 'We could not load requests',
        message: provider.requestsErrorMessage!,
        actionLabel: 'Reload',
        onAction: provider.loadRequests,
      );
    }

    if (provider.requests.isEmpty) {
      return const _StateCard(
        icon: Icons.inbox_rounded,
        title: 'You do not have new requests',
        message: 'Incoming requests will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadRequests,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 24),
        itemCount: provider.requests.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = provider.requests[index];
          return _RequestTile(request: request);
        },
      ),
    );
  }
}

class _FindFriendsSheet extends StatefulWidget {
  const _FindFriendsSheet();

  @override
  State<_FindFriendsSheet> createState() => _FindFriendsSheetState();
}

class _FindFriendsSheetState extends State<_FindFriendsSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: GlassContainer(
        color: const Color(0xFF063970),
        opacity: 0.96,
        blur: 20,
        borderRadius: 26,
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.74,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Find friends',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.58),
                    ),
                    hintText: 'Search by name or email',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.72,
                        ),
                        width: 1.4,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onChanged: provider.searchDebounced,
                  onSubmitted: provider.searchUsers,
                ),
                const SizedBox(height: 16),
                if (provider.searchErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      provider.searchErrorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Expanded(
                  child: provider.isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : provider.searchResults.isEmpty
                      ? const _StateCard(
                          icon: Icons.manage_search_rounded,
                          title: 'Search users',
                          message: 'Type part of a name or email.',
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: provider.searchResults.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final result = provider.searchResults[index];
                            return _SearchResultTile(result: result);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.user, this.trailing, this.framed = true});

  final FriendUser user;
  final Widget? trailing;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tile = Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          AppAvatar(imageUrl: user.avatarUrl, radius: 23),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (user.email != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    user.email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.56),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );

    if (!framed) {
      return tile;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: tile,
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result});

  final FriendSearchResult result;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();
    final isLoading = provider.isActionLoading(result.user.id);
    final canInvite =
        result.relationshipStatus == FriendRelationshipStatus.available;

    return _PersonTile(
      user: result.user,
      trailing: canInvite
          ? FilledButton(
              onPressed: isLoading ? null : () => provider.sendRequest(result),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Send',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
            )
          : _StatusPill(
              icon: Icons.info_rounded,
              label: result.relationshipStatus.label,
              color: Theme.of(context).colorScheme.primary,
            ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final FriendRequest request;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();
    final isLoading = provider.isActionLoading(request.id);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _PersonTile(user: request.sender, framed: false),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => provider.declineRequest(request),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => provider.acceptRequest(request),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: theme.colorScheme.tertiary, size: 32),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
