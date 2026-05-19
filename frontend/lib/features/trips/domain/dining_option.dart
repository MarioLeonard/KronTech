class DiningOption {
  const DiningOption({
    required this.name,
    required this.city,
    required this.area,
    required this.cuisine,
    required this.recommendedFor,
    required this.estimatedMealCost,
    required this.note,
  });

  final String name;
  final String city;
  final String area;
  final String cuisine;
  final String recommendedFor;
  final num estimatedMealCost;
  final String note;

  factory DiningOption.fromJson(Map<String, dynamic> json) {
    return DiningOption(
      name: _readString(json, 'name', 'Loc pentru masa'),
      city: _readString(json, 'city', 'City unspecified'),
      area: _readString(json, 'area', 'Area unspecified'),
      cuisine: _readString(json, 'cuisine', 'Bucatarie mixta'),
      recommendedFor: _readString(json, 'recommendedFor', 'masa'),
      estimatedMealCost: _readNum(json, 'estimatedMealCost'),
      note: _readString(json, 'note', 'Cost estimativ per persoana.'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'area': area,
      'cuisine': cuisine,
      'recommendedFor': recommendedFor,
      'estimatedMealCost': estimatedMealCost,
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
