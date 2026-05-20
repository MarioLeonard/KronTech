import 'package:flutter/material.dart';
import 'package:frontend/components/feature_card.dart';

class FeatureRow extends StatelessWidget {
  final FeatureCard card;
  final Widget textContent;
  final bool isCardLeft;

  const FeatureRow({
    required this.card,
    required this.textContent,
    required this.isCardLeft,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 64.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isCardLeft) ...[
                  Expanded(flex: 5, child: Center(child: card)),
                  const SizedBox(width: 64),
                  Expanded(flex: 6, child: textContent),
                ] else ...[
                  Expanded(flex: 6, child: textContent),
                  const SizedBox(width: 64),
                  Expanded(flex: 5, child: Center(child: card)),
                ],
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textContent,
                const SizedBox(height: 32),
                Center(child: card),
              ],
            ),
          );
        }
      },
    );
  }
}
