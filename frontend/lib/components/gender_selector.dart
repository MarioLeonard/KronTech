import 'package:flutter/material.dart';

/// Custom gender selector component with radio buttons
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

class _GenderSelectorState extends State<GenderSelector> {
  late String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialValue;
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
        const SizedBox(height: 12),
        // The new way to manage radio state in Flutter 3.32+
        RadioGroup<String>(
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
            widget.onChanged(value ?? '');
          },
          child: Column(
            children: widget.genders.map((gender) {
              return RadioListTile<String>(
                title: Text(gender),
                value: gender,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
