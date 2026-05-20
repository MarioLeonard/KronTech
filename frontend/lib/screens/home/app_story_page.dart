part of '../home_screen.dart';

class _AppStoryPage extends StatelessWidget {
  final VoidCallback onPrimaryPressed;

  const _AppStoryPage({required this.onPrimaryPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'From idea to itinerary, in a second',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: const [
                  _StoryPoint(
                    icon: Icons.route_rounded,
                    title: 'Route-first planning',
                    text: 'Turn destination ideas into days that make sense.',
                  ),
                  _StoryPoint(
                    icon: Icons.forum_rounded,
                    title: 'Built for friends',
                    text: 'Keep travel decisions close to the people joining.',
                  ),
                  _StoryPoint(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Less decision fatigue',
                    text: 'Focus on the trip instead of juggling tabs.',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: FilledButton.icon(
                  onPressed: onPrimaryPressed,
                  icon: const Icon(Icons.explore_rounded, size: 20),
                  label: const Text(
                    'Start with a trip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
