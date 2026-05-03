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
            child: TextButton(
              onPressed: onSecondaryPressed!,
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: Text(secondaryLabel!),
            ),
          ),
        if (showSecondary) const SizedBox(width: 14),
        if (showPrimary)
          Expanded(
            flex: showSecondary ? 2 : 1,
            child: SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: isBusy ? null : onPrimaryPressed,
                style: FilledButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isBusy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(primaryLabel),
              ),
            ),
          ),
      ],
    );
  }
}
