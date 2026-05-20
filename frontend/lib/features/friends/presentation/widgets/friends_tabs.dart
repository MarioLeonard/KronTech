part of '../screens/friends_screen.dart';

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
