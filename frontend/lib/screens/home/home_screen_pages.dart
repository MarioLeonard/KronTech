part of '../home_screen.dart';

class _WelcomeLandingPage extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final FeatureCard imageCard;
  final VoidCallback onPrimaryPressed;

  const _WelcomeLandingPage({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.imageCard,
    required this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;

              final textContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    subtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.68),
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
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

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    textContent,
                    const SizedBox(height: 28),
                    imageCard,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: textContent),
                  const SizedBox(width: 52),
                  Expanded(flex: 5, child: Center(child: imageCard)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
