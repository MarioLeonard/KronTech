import 'package:flutter/material.dart';

/// Custom form field component for text inputs
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

class _CustomFormFieldState extends State<CustomFormField> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CustomFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = widget.initialValue ?? '';
    if (_controller.text != nextValue) {
      _controller.value = TextEditingValue(
        text: nextValue,
        selection: TextSelection.collapsed(offset: nextValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate() {
    if (widget.validator != null) {
      final error = widget.validator!(_controller.text);
      setState(() {
        _errorText = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (widget.required)
                TextSpan(
                  text: ' *',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          obscureText: widget.obscureText,
          onChanged: (value) {
            _validate();
            widget.onChanged(value);
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            errorText: _errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errorText != null ? Colors.red : Colors.white,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errorText != null ? Colors.red : Colors.white,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
