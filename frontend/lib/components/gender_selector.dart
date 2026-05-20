import 'package:flutter/material.dart';

part 'gender_selector_state.dart';

class GenderSelector extends StatefulWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final List<String> genders;
  final bool required;

  const GenderSelector({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.genders = const ['Male', 'Female', 'Other'],
    this.required = true,
  });

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}
