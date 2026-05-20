import 'package:flutter/material.dart';

part 'custom_date_picker_state.dart';

class CustomDatePicker extends StatefulWidget {
  final String label;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;
  final bool required;

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.required = true,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}
