import 'package:flutter/material.dart';

import '../../data/city_catalog.dart';
import '../../data/country_catalog.dart';
import '../../domain/city_location_constants.dart';
import '../../domain/city_option.dart';

class CityLocationField extends StatefulWidget {
  const CityLocationField({
    super.key,
    required this.value,
    required this.country,
    required this.onChanged,
    this.errorText,
    CityCatalog? cityCatalog,
    CountryCatalog? countryCatalog,
  }) : _cityCatalog = cityCatalog,
       _countryCatalog = countryCatalog;

  final String value;
  final String country;
  final Future<void> Function(String value) onChanged;
  final String? errorText;
  final CityCatalog? _cityCatalog;
  final CountryCatalog? _countryCatalog;

  @override
  State<CityLocationField> createState() => _CityLocationFieldState();
}

class _CityLocationFieldState extends State<CityLocationField> {
  late final TextEditingController _controller;
  late final CityCatalog _cityCatalog;
  late final CountryCatalog _countryCatalog;

  bool _hasSelectedCity = false;
  Future<List<CityOption>>? _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _cityCatalog = widget._cityCatalog ?? CityCatalog();
    _countryCatalog = widget._countryCatalog ?? CountryCatalog();
    _hasSelectedCity = widget.value.trim().isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant CityLocationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasSelectedCity && widget.value.isEmpty) {
      return;
    }

    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
      _hasSelectedCity = widget.value.trim().isNotEmpty;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectCity(String value) async {
    final city = value.trim();
    _controller.value = TextEditingValue(
      text: city,
      selection: TextSelection.collapsed(offset: city.length),
    );
    setState(() => _hasSelectedCity = true);
    await widget.onChanged(city);
  }

  void _handleTextChanged(String value) {
    final countryCode = _countryCatalog.countryCodeFor(widget.country);
    setState(() {
      _hasSelectedCity = false;
      _suggestionsFuture = _cityCatalog.suggestionsFor(
        countryCode: countryCode,
        query: value,
      );
    });
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countryCode = _countryCatalog.countryCodeFor(widget.country);
    final query = _controller.text.trim();
    final shouldShowSuggestions =
        query.length >= CityLocationConstants.minCityQueryLength &&
        !_hasSelectedCity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          enabled: countryCode.isNotEmpty,
          onChanged: _handleTextChanged,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: countryCode.isEmpty
                ? CityLocationConstants.noCountryText
                : CityLocationConstants.hintText,
            prefixIcon: const Icon(Icons.location_city_rounded),
            suffixIcon: _hasSelectedCity
                ? const Icon(Icons.check_circle_rounded, color: Colors.white)
                : null,
            errorText: widget.errorText,
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.errorText != null
                    ? theme.colorScheme.error
                    : Colors.white,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        AnimatedSize(
          duration: CityLocationConstants.suggestionsAnimationDuration,
          curve: CityLocationConstants.suggestionsAnimationCurve,
          alignment: Alignment.topCenter,
          child: shouldShowSuggestions
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: FutureBuilder<List<CityOption>>(
                    future: _suggestionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      return _CitySuggestions(
                        cities: snapshot.data ?? const [],
                        onSelected: (city) => _selectCity(city.name),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CitySuggestions extends StatelessWidget {
  const _CitySuggestions({required this.cities, required this.onSelected});

  final List<CityOption> cities;
  final Future<void> Function(CityOption value) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (cities.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white),
          color: theme.colorScheme.surface.withValues(alpha: 0.75),
        ),
        child: Text(
          CityLocationConstants.noMatchesText,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white),
        color: theme.colorScheme.surface.withValues(alpha: 0.75),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: cities.map((city) {
          final isLast = city == cities.last;
          return DecoratedBox(
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
            ),
            child: ListTile(
              dense: true,
              title: Text(city.name),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onSelected(city),
            ),
          );
        }).toList(),
      ),
    );
  }
}
