import 'package:flutter/material.dart';

class OnboardingNavigationBar extends StatelessWidget {
  const OnboardingNavigationBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
    this.isBusy = false,
  });

  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (secondaryLabel != null && onSecondaryPressed != null)
          Expanded(
            child: _AnimatedActionButton(
              onPressed: onSecondaryPressed!,
              filled: false,
              child: Text(secondaryLabel!),
            ),
          ),
        if (secondaryLabel != null && onSecondaryPressed != null)
          const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: _AnimatedActionButton(
            onPressed: isBusy ? null : onPrimaryPressed,
            filled: true,
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

class _AnimatedActionButton extends StatefulWidget {
  const _AnimatedActionButton({
    required this.child,
    required this.filled,
    required this.onPressed,
  });

  final Widget child;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final scale = _pressed ? 0.985 : (_hovered ? 1.01 : 1.0);
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: widget.filled
              ? ElevatedButton(onPressed: widget.onPressed, child: widget.child)
              : OutlinedButton(
                  onPressed: widget.onPressed,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface.withValues(
                      alpha: enabled ? 0.6 : 0.3,
                    ),
                  ),
                  child: widget.child,
                ),
        ),
      ),
    );
  }
}
