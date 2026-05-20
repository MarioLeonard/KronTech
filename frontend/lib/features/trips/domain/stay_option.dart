class StayOption {
  const StayOption({
    required this.name,
    required this.city,
    required this.area,
    required this.type,
    required this.estimatedNightlyCost,
    required this.source,
    required this.bookingSearchUrl,
    required this.airbnbSearchUrl,
    required this.isSearchSuggestion,
    required this.note,
  });

  final String name;
  final String city;
  final String area;
  final String type;
  final num estimatedNightlyCost;
  final String source;
  final String bookingSearchUrl;
  final String airbnbSearchUrl;
  final bool isSearchSuggestion;
  final String note;

  factory StayOption.fromJson(Map<String, dynamic> json) {
    return StayOption(
      name: _readString(json, 'name', 'Recommended accommodation'),
      city: _readString(json, 'city', 'City unspecified'),
      area: _readString(json, 'area', 'Area unspecified'),
      type: _readString(json, 'type', 'other'),
      estimatedNightlyCost: _readNum(json, 'estimatedNightlyCost'),
      source: _readString(json, 'source', 'Search suggestion'),
      bookingSearchUrl: _readString(json, 'bookingSearchUrl', ''),
      airbnbSearchUrl: _readString(json, 'airbnbSearchUrl', ''),
      isSearchSuggestion: json['isSearchSuggestion'] is bool
          ? json['isSearchSuggestion'] as bool
          : true,
      note: _readString(
        json,
        'note',
        'Search suggestion, not verified availability.',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'area': area,
      'type': type,
      'estimatedNightlyCost': estimatedNightlyCost,
      'source': source,
      'bookingSearchUrl': bookingSearchUrl,
      'airbnbSearchUrl': airbnbSearchUrl,
      'isSearchSuggestion': isSearchSuggestion,
      'note': note,
    };
  }
}

num _readNum(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) {
    return value;
  }
  if (value is String) {
    return num.tryParse(value.replaceAll(',', '.')) ?? 0;
  }
  return 0;
}

String _readString(Map<String, dynamic> json, String key, String fallback) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return fallback;
}
