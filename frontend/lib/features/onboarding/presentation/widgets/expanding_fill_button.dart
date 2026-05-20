part of 'onboarding_navigation_bar.dart';

class _ExpandingFillButton extends StatefulWidget {
  const _ExpandingFillButton({
    required this.label,
    required this.animationKey,
    required this.isBusy,
    required this.onPressed,
  });

  final String label;
  final Object animationKey;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  State<_ExpandingFillButton> createState() => _ExpandingFillButtonState();
}
