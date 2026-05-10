import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
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

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_handleScroll);
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Prieteni',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showSearchSheet(context),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Gaseste prieteni'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Prieteni'),
                  Tab(text: 'Cereri'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FriendsTab(
                    scrollController: _scrollController,
                    onOpenChat: widget.onOpenChat,
                  ),
                  const _RequestsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: context.read<FriendsProvider>(),
          child: const _FindFriendsSheet(),
        );
      },
    );
  }
}

class _FriendsTab extends StatelessWidget {
  const _FriendsTab({required this.scrollController, this.onOpenChat});

  final ScrollController scrollController;
  final ValueChanged<String>? onOpenChat;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();
    final theme = Theme.of(context);

    if (provider.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.friends.isEmpty) {
      return _StateCard(
        icon: Icons.error_outline_rounded,
        title: 'Nu am putut incarca prietenii',
        message: provider.errorMessage!,
        actionLabel: 'Incearca din nou',
        onAction: () => provider.loadFriends(refresh: true),
      );
    }

    if (provider.friends.isEmpty) {
      return const _StateCard(
        icon: Icons.group_outlined,
        title: 'Nu ai prieteni inca',
        message: 'Cauta persoane din aplicatie si trimite prima cerere.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadFriends(refresh: true),
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: provider.friends.length + (provider.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
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
            trailing: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  avatar: Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  label: const Text('Prieten'),
                ),
                IconButton.filledTonal(
                  tooltip: 'Chat',
                  onPressed: friend.conversationId == null || onOpenChat == null
                      ? null
                      : () => onOpenChat!(friend.conversationId!),
                  icon: const Icon(Icons.chat_bubble_rounded),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();

    if (provider.isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.requestsErrorMessage != null && provider.requests.isEmpty) {
      return _StateCard(
        icon: Icons.error_outline_rounded,
        title: 'Nu am putut incarca cererile',
        message: provider.requestsErrorMessage!,
        actionLabel: 'Reincarca',
        onAction: provider.loadRequests,
      );
    }

    if (provider.requests.isEmpty) {
      return const _StateCard(
        icon: Icons.inbox_rounded,
        title: 'Nu ai cereri noi',
        message: 'Cererile primite vor aparea aici.',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadRequests,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: provider.requests.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
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
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.74,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gaseste prieteni',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Cauta dupa nume sau email',
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
                  ),
                ),
              ),
            Expanded(
              child: provider.isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : provider.searchResults.isEmpty
                  ? const _StateCard(
                      icon: Icons.manage_search_rounded,
                      title: 'Cauta utilizatori',
                      message: 'Scrie cel putin o parte din nume sau email.',
                    )
                  : ListView.separated(
                      itemCount: provider.searchResults.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final result = provider.searchResults[index];
                        return _SearchResultTile(result: result);
                      },
                    ),
            ),
          ],
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

    final tile = ListTile(
      leading: AppAvatar(imageUrl: user.avatarUrl, radius: 20),
      title: Text(user.name, style: theme.textTheme.titleSmall),
      subtitle: user.email == null ? null : Text(user.email!),
      trailing: trailing,
    );

    if (!framed) {
      return tile;
    }

    return Card(child: tile);
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
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Trimite'),
            )
          : Chip(label: Text(result.relationshipStatus.label)),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                  label: const Text('Refuza'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => provider.acceptRequest(request),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Accepta'),
                ),
              ],
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
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: theme.colorScheme.tertiary, size: 32),
                const SizedBox(height: 12),
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
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
