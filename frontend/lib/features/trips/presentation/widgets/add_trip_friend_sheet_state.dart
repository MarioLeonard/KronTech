part of '../screens/trip_details_screen.dart';

class _AddTripFriendSheetState extends State<_AddTripFriendSheet> {
  final FriendsApiService _friendsService = FriendsApiService();
  late Future<List<FriendUser>> _friendsFuture;
  String? _addingFriendId;

  @override
  void initState() {
    super.initState();
    _friendsFuture = _loadFriends();
  }

  Future<List<FriendUser>> _loadFriends() async {
    final user = context.read<AuthProvider>().user;
    final idToken = user?.idToken ?? '';
    if (idToken.isEmpty) {
      return const [];
    }

    final page = await _friendsService.fetchFriends(
      idToken: idToken,
      page: 1,
      limit: 50,
    );
    final addedIds = widget.trip.friends.map((friend) => friend.id).toSet();
    return page.friends
        .where((friend) => !addedIds.contains(friend.id))
        .toList();
  }

  Future<void> _addFriend(FriendUser friend) async {
    setState(() => _addingFriendId = friend.id);
    final didAdd = await widget.onAddFriend(friend);
    if (mounted) {
      if (didAdd) {
        Navigator.of(context).pop();
      } else {
        setState(() => _addingFriendId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: GlassContainer(
              color: const Color(0xFF0E5A90),
              opacity: 0.22,
              blur: 16,
              borderRadius: 24,
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 18),
                    _TripSheetCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add friends',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Only people from your friends list can be added.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.62),
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TripSheetCard(
                      child: FutureBuilder<List<FriendUser>>(
                        future: _friendsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const SizedBox(
                              height: 180,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final friends = snapshot.data ?? const [];
                          if (friends.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 26),
                              child: _EmptySection(
                                message:
                                    'There are no friends available to add.',
                              ),
                            );
                          }

                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 420),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: friends.length,
                              separatorBuilder: (_, _) => Divider(
                                color: Colors.white.withValues(alpha: 0.08),
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final friend = friends[index];
                                final isAdding = _addingFriendId == friend.id;
                                return _FriendPickerRow(
                                  friend: friend,
                                  isAdding: isAdding,
                                  onTap: _addingFriendId == null
                                      ? () => _addFriend(friend)
                                      : null,
                                );
                              },
                            ),
                          );
                        },
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
}
