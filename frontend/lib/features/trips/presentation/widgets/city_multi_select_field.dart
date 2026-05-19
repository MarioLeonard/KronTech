import 'package:flutter/material.dart';

class CityMultiSelectField extends StatefulWidget {
  const CityMultiSelectField({
    required this.cities,
    required this.onChanged,
    required this.enabled,
    super.key,
  });

  final List<String> cities;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  @override
  State<CityMultiSelectField> createState() => _CityMultiSelectFieldState();
}

class _CityMultiSelectFieldState extends State<CityMultiSelectField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addCity() {
    final city = _controller.text.trim();
    if (city.isEmpty) {
      return;
    }

    final exists = widget.cities.any(
      (item) => item.toLowerCase() == city.toLowerCase(),
    );
    if (!exists) {
      widget.onChanged([...widget.cities, city]);
    }
    _controller.clear();
  }

  void _removeCity(String city) {
    widget.onChanged(widget.cities.where((item) => item != city).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addCity(),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_city_rounded),
            labelText: 'Cities',
            hintText: 'Add city',
            suffixIcon: IconButton(
              tooltip: 'Add city',
              onPressed: widget.enabled ? _addCity : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ),
        if (widget.cities.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.cities
                .map(
                  (city) => InputChip(
                    label: Text(city),
                    onDeleted: widget.enabled ? () => _removeCity(city) : null,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
