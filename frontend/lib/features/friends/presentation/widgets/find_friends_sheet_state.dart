part of '../screens/friends_screen.dart';

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
