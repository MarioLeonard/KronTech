part of 'trip_date_range_fields.dart';

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
    super.key,
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
