import 'package:flutter/material.dart';

part 'custom_form_field_state.dart';

class CustomFormField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final bool obscureText;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool required;

  const CustomFormField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.obscureText = false,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.required = true,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}
