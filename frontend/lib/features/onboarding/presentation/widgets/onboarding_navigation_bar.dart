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

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.center,
      child: Row(
        children: [
          if (showSecondary)
            Expanded(
              child: _AnimatedActionButton(
                onPressed: onSecondaryPressed!,
                filled: false,
                child: Text(secondaryLabel!),
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                ),
              );
            },
            child: showPrimary && showSecondary
                ? const SizedBox(key: ValueKey('primary-gap'), width: 14)
                : const SizedBox.shrink(key: ValueKey('no-primary-gap')),
          ),
          if (showPrimary)
            Expanded(
              flex: showSecondary ? 2 : 1,
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
      ),
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
