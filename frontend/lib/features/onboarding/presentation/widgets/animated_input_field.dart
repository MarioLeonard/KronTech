import 'package:flutter/material.dart';

class AnimatedInputField extends StatefulWidget {
  const AnimatedInputField({
    super.key,
    required this.label,
    required this.value,
    required this.hintText,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.autofocus = true,
  });

  final String label;
  final String value;
  final String hintText;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final bool autofocus;

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AnimatedInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null;
    final isFocused = _focusNode.hasFocus;
    final hasValue = _controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          style:
              theme.textTheme.titleMedium?.copyWith(
                fontSize: 15,
                color: isFocused
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface,
              ) ??
              const TextStyle(),
          child: Text(widget.label),
        ),
        const SizedBox(height: 14),
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? theme.colorScheme.error.withValues(alpha: 0.12)
                    : theme.colorScheme.primary.withValues(
                        alpha: isFocused ? 0.18 : 0.0,
                      ),
                blurRadius: isFocused ? 30 : 18,
                offset: Offset(0, isFocused ? 14 : 8),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(scale: curved, child: child),
                  );
                },
                child: hasValue && !hasError
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('valid-input'),
                        color: theme.colorScheme.secondary,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty-input')),
              ),
              errorText: widget.errorText,
            ),
          ),
        ),
      ],
    );
  }
}
