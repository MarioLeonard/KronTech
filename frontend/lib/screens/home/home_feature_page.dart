part of '../home_screen.dart';

class _HomeFeaturePage extends StatelessWidget {
  final FeatureCard card;
  final Widget textContent;
  final bool isCardLeft;

  const _HomeFeaturePage({
    required this.card,
    required this.textContent,
    required this.isCardLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: FeatureRow(
            isCardLeft: isCardLeft,
            card: card,
            textContent: textContent,
          ),
        ),
      ),
    );
  }
}
