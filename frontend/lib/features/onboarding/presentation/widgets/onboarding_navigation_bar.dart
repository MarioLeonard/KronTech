import 'package:flutter/material.dart';

part 'expanding_fill_button.dart';
part 'expanding_fill_button_state.dart';

class OnboardingNavigationBar extends StatelessWidget {
  const OnboardingNavigationBar({
    super.key,
    required this.primaryLabel,
    required this.showPrimary,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
    required this.animationKey,
    this.isBusy = false,
  });

  final String primaryLabel;
  final bool showPrimary;
  final VoidCallback onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final Object animationKey;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final showSecondary = secondaryLabel != null && onSecondaryPressed != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offsetAnimation,
                child: SizeTransition(
                  axisAlignment: -1,
                  sizeFactor: animation,
                  child: child,
                ),
              ),
            );
          },
          child: showPrimary
              ? SizedBox(
                  key: ValueKey(primaryLabel),
                  width: double.infinity,
                  height: 52,
                  child: _ExpandingFillButton(
                    label: primaryLabel,
                    animationKey: animationKey,
                    isBusy: isBusy,
                    onPressed: onPrimaryPressed,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty-primary')),
        ),
        if (showSecondary) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSecondaryPressed!,
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: Text(secondaryLabel!),
          ),
        ],
      ],
    );
  }
}
