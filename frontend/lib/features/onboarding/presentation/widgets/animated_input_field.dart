import 'package:flutter/material.dart';

part 'animated_input_field_state.dart';

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
