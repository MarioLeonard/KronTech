import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

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
  static const _minQueryLength = 3;
  static const _maxSuggestions = 7;

  final _controller = TextEditingController();
  Future<List<csc.City>>? _allCitiesFuture;
  List<csc.City> _suggestions = const [];
  bool _isLoadingSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<csc.City>> _loadCities() {
    return _allCitiesFuture ??= csc.getAllCities();
  }

  Future<void> _handleQueryChanged(String value) async {
    final query = value.trim().toLowerCase();
    if (query.length < _minQueryLength) {
      setState(() {
        _suggestions = const [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    setState(() => _isLoadingSuggestions = true);
    final cities = await _loadCities();
    if (!mounted || _controller.text.trim().toLowerCase() != query) {
      return;
    }

    final selected = widget.cities.map((city) => city.toLowerCase()).toSet();
    final matches =
        cities.where((city) {
          final displayValue = _cityDisplayValue(city).toLowerCase();
          return !selected.contains(displayValue) &&
              city.name.toLowerCase().contains(query);
        }).toList()..sort((first, second) {
          final firstName = first.name.toLowerCase();
          final secondName = second.name.toLowerCase();
          final firstStarts = firstName.startsWith(query);
          final secondStarts = secondName.startsWith(query);
          if (firstStarts != secondStarts) {
            return firstStarts ? -1 : 1;
          }
          return first.name.compareTo(second.name);
        });

    setState(() {
      _suggestions = matches.take(_maxSuggestions).toList();
      _isLoadingSuggestions = false;
    });
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
    setState(() => _suggestions = const []);
  }

  void _selectCity(csc.City city) {
    final value = _cityDisplayValue(city);
    final exists = widget.cities.any(
      (item) => item.toLowerCase() == value.toLowerCase(),
    );
    if (!exists) {
      widget.onChanged([...widget.cities, value]);
    }
    _controller.clear();
    setState(() => _suggestions = const []);
  }

  void _removeCity(String city) {
    widget.onChanged(widget.cities.where((item) => item != city).toList());
  }

  String _cityDisplayValue(csc.City city) {
    return '${city.name}, ${city.countryCode}';
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final shouldShowSuggestions = query.length >= _minQueryLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          textInputAction: TextInputAction.done,
          onChanged: _handleQueryChanged,
          onSubmitted: (_) => _addCity(),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_city_rounded),
            labelText: 'Destination',
            hintText: 'Select one or more cities',
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: shouldShowSuggestions
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _CitySuggestions(
                    cities: _suggestions,
                    isLoading: _isLoadingSuggestions,
                    onSelected: _selectCity,
                  ),
                )
              : const SizedBox.shrink(),
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

class _CitySuggestions extends StatelessWidget {
  const _CitySuggestions({
    required this.cities,
    required this.isLoading,
    required this.onSelected,
  });

  final List<csc.City> cities;
  final bool isLoading;
  final ValueChanged<csc.City> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF063970).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: isLoading
              ? const Padding(
                  key: ValueKey('loading'),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : cities.isEmpty
              ? Padding(
                  key: const ValueKey('empty'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Text(
                    'No matching cities',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Column(
                  key: ValueKey('results-${cities.length}'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0; index < cities.length; index++)
                      _CitySuggestionTile(
                        city: cities[index],
                        isLast: index == cities.length - 1,
                        onTap: () => onSelected(cities[index]),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CitySuggestionTile extends StatelessWidget {
  const _CitySuggestionTile({
    required this.city,
    required this.isLast,
    required this.onTap,
  });

  final csc.City city;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: const Icon(
          Icons.location_on_outlined,
          color: Colors.white,
          size: 18,
        ),
        title: Text(
          city.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          city.countryCode,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.54),
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        onTap: onTap,
      ),
    );
  }
}
