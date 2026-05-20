part of '../main_shell.dart';

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
