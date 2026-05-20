part of 'city_location_field.dart';

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
