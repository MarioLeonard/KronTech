import 'package:flutter/material.dart';

class TripDateRangeFields extends StatelessWidget {
  const TripDateRangeFields({
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.enabled,
    super.key,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final bool enabled;

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime? initialDate,
    required ValueChanged<DateTime> onChanged,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 460;
        final fields = [
          _DateField(
            label: 'Start date',
            value: _formatDate(startDate),
            enabled: enabled,
            onTap: () => _pickDate(
              context: context,
              initialDate: startDate,
              onChanged: onStartDateChanged,
            ),
          ),
          _DateField(
            label: 'Data final',
            value: _formatDate(endDate),
            enabled: enabled,
            onTap: () => _pickDate(
              context: context,
              initialDate: endDate ?? startDate,
              onChanged: onEndDateChanged,
            ),
          ),
        ];

        if (isCompact) {
          return Column(
            children: [fields.first, const SizedBox(height: 12), fields.last],
          );
        }

        return Row(
          children: [
            Expanded(child: fields.first),
            const SizedBox(width: 12),
            Expanded(child: fields.last),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(text: value),
      onTap: enabled ? onTap : null,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_month_rounded),
        labelText: label,
        hintText: 'Choose date',
      ),
    );
  }
}
