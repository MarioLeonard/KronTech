import 'package:flutter/material.dart';

class OnboardingNavigationBar extends StatelessWidget {
  const OnboardingNavigationBar({
    super.key,
    required this.primaryLabel,
    required this.showPrimary,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
    this.isBusy = false,
  });

  final String primaryLabel;
  final bool showPrimary;
  final VoidCallback onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final showSecondary = secondaryLabel != null && onSecondaryPressed != null;

    return Row(
      children: [
        if (showSecondary)
          Expanded(
            child: ElevatedButton(
              onPressed: onSecondaryPressed!,
              child: Text(secondaryLabel!),
            ),
          ),
        if (showSecondary) const SizedBox(width: 14),
        if (showPrimary)
          Expanded(
            flex: showSecondary ? 2 : 1,
            child: ElevatedButton(
              onPressed: isBusy ? null : onPrimaryPressed,
              child: isBusy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(primaryLabel),
            ),
          ),
      ],
    );
  }
}
