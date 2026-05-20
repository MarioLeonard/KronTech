part of 'city_multi_select_field.dart';

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
