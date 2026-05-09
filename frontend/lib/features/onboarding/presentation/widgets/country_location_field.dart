import 'package:flutter/material.dart';

import '../../data/country_catalog.dart';
import '../../data/location_country_service.dart';
import '../../domain/country_location_constants.dart';
import '../../domain/country_option.dart';

class CountryLocationField extends StatefulWidget {
  const CountryLocationField({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.onLocationDetected,
    CountryCatalog? countryCatalog,
    LocationCountryService? locationCountryService,
  }) : _countryCatalog = countryCatalog,
       _locationCountryService = locationCountryService;

  final String value;
  final Future<void> Function(String value) onChanged;
  final String? errorText;
  final Future<void> Function(String country, String city, String street)?
  onLocationDetected;
  final CountryCatalog? _countryCatalog;
  final LocationCountryService? _locationCountryService;

  @override
  State<CountryLocationField> createState() => _CountryLocationFieldState();
}

class _CountryLocationFieldState extends State<CountryLocationField> {
  late final TextEditingController _controller;
  late final CountryCatalog _countryCatalog;
  late final LocationCountryService _locationCountryService;

  bool _isLocating = false;
  bool _hasSelectedCountry = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _countryCatalog = widget._countryCatalog ?? CountryCatalog();
    _locationCountryService =
        widget._locationCountryService ?? const LocationCountryService();
    _hasSelectedCountry = widget.value.trim().isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant CountryLocationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasSelectedCountry && widget.value.isEmpty) {
      return;
    }

    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final place = await _locationCountryService.detectPlace();
      await _setCountry(place.country);
      if (place.city.isNotEmpty || place.street.isNotEmpty) {
        await widget.onLocationDetected?.call(
          place.country,
          place.city,
          place.street,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationError = CountryLocationConstants.locationFallbackError;
      });
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _setCountry(String value) async {
    final country = value.trim();
    _controller.value = TextEditingValue(
      text: country,
      selection: TextSelection.collapsed(offset: country.length),
    );
    setState(() {
      _hasSelectedCountry = true;
      _locationError = null;
    });
    await widget.onChanged(country);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = widget.errorText ?? _locationError;
    final hasError = errorText != null;
    final query = _controller.text.trim();
    final matchingCountries = _countryCatalog.suggestionsFor(query);
    final shouldShowSuggestions =
        query.length >= CountryLocationConstants.minCountryQueryLength &&
        !_hasSelectedCountry;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            setState(() {
              _hasSelectedCountry = false;
              _locationError = null;
            });
            widget.onChanged('');
          },
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: CountryLocationConstants.hintText,
            prefixIcon: const Icon(Icons.public_rounded),
            suffixIcon: IconButton(
              onPressed: _isLocating ? null : _useCurrentLocation,
              tooltip: CountryLocationConstants.locationTooltip,
              icon: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded),
            ),
            errorText: errorText,
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? theme.colorScheme.error : Colors.white,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 2),
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
          duration: CountryLocationConstants.suggestionsAnimationDuration,
          curve: CountryLocationConstants.suggestionsAnimationCurve,
          alignment: Alignment.topCenter,
          child: shouldShowSuggestions
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _CountrySuggestions(
                    countries: matchingCountries,
                    onSelected: (country) => _setCountry(country.name),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CountrySuggestions extends StatelessWidget {
  const _CountrySuggestions({
    required this.countries,
    required this.onSelected,
  });

  final List<CountryOption> countries;
  final Future<void> Function(CountryOption value) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (countries.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white),
          color: theme.colorScheme.surface.withValues(alpha: 0.75),
        ),
        child: Text(
          CountryLocationConstants.noMatchesText,
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
        children: countries.map((country) {
          final isLast = country == countries.last;
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
              title: Text(country.name),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onSelected(country),
            ),
          );
        }).toList(),
      ),
    );
  }
}
