import 'package:flutter/material.dart';

part 'custom_checkbox_state.dart';
part 'interest_selector.dart';
part 'interest_selector_state.dart';

class CustomCheckbox extends StatefulWidget {
  final String label;
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final String? description;

  const CustomCheckbox({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.description,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}
