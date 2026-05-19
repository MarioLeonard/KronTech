class TripActivity {
  const TripActivity({
    required this.timeRange,
    required this.title,
    required this.location,
    required this.description,
    required this.estimatedCost,
    required this.costNote,
    required this.distanceFromPreviousKm,
    required this.travelTimeFromPrevious,
    required this.transportMode,
    required this.tags,
  });

  final String timeRange;
  final String title;
  final String location;
  final String description;
  final num estimatedCost;
  final String costNote;
  final num distanceFromPreviousKm;
  final String travelTimeFromPrevious;
  final String transportMode;
  final List<String> tags;

  factory TripActivity.fromJson(Map<String, dynamic> json) {
    return TripActivity(
      timeRange: _readString(json, 'timeRange', 'Ora nespecificata'),
      title: _readString(json, 'title', 'Recommended activity'),
      location: _readString(json, 'location', 'Locatie nespecificata'),
      description: _readString(json, 'description', 'Description unavailable.'),
      estimatedCost: _readNum(json, 'estimatedCost'),
      costNote: _readString(json, 'costNote', 'Cost aproximativ.'),
      distanceFromPreviousKm: _readNum(json, 'distanceFromPreviousKm'),
      travelTimeFromPrevious: _readString(
        json,
        'travelTimeFromPrevious',
        'Duration unavailable',
      ),
      transportMode: _readString(json, 'transportMode', 'other'),
      tags: _readStringList(json['tags']),
    );
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

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
