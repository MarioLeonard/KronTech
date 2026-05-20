part of 'onboarding_navigation_bar.dart';

class _ExpandingFillButtonState extends State<_ExpandingFillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _fillAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _ExpandingFillButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationKey != widget.animationKey ||
        oldWidget.label != widget.label) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final states = widget.isBusy ? {WidgetState.disabled} : <WidgetState>{};
    final buttonStyle = theme.filledButtonTheme.style;
    final fillColor =
        buttonStyle?.backgroundColor?.resolve(states) ??
        theme.colorScheme.tertiary;
    final foregroundColor =
        buttonStyle?.foregroundColor?.resolve(states) ??
        theme.colorScheme.onTertiary;
    final disabledColor =
        buttonStyle?.backgroundColor?.resolve({WidgetState.disabled}) ??
        theme.disabledColor;
    final borderRadius = BorderRadius.circular(8);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: widget.isBusy ? disabledColor : Colors.transparent,
        child: InkWell(
          onTap: widget.isBusy ? null : widget.onPressed,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if (!widget.isBusy)
                AnimatedBuilder(
                  animation: _fillAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fillAnimation.value,
                      child: child,
                    );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: borderRadius,
                    ),
                  ),
                ),
              Center(
                child: widget.isBusy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.label,
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
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
