part of '../main_shell.dart';

class _ShellPageTransitionState extends State<_ShellPageTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _currentIndex = 0;
  int? _previousIndex;
  bool _incomingFromBottom = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..value = 1;
  }

  @override
  void didUpdateWidget(covariant _ShellPageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == oldWidget.selectedIndex) {
      return;
    }

    _previousIndex = _currentIndex;
    _incomingFromBottom = widget.selectedIndex > _currentIndex;
    _currentIndex = widget.selectedIndex;
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) {
        setState(() => _previousIndex = null);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );

    return ClipRect(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value;
          final direction = _incomingFromBottom ? 1.0 : -1.0;
          final outgoingOffset = Offset(0, -direction * progress);
          final incomingOffset = Offset(0, direction * (1 - progress));

          return Stack(
            fit: StackFit.expand,
            children: [
              for (var index = 0; index < widget.children.length; index++)
                _ShellPageSlot(
                  key: ValueKey('shell-page-$index'),
                  isVisible: index == _currentIndex || index == _previousIndex,
                  isActive: index == _currentIndex,
                  offset: index == _currentIndex
                      ? incomingOffset
                      : index == _previousIndex
                      ? outgoingOffset
                      : Offset.zero,
                  child: widget.children[index],
                ),
            ],
          );
        },
      ),
    );
  }
}
