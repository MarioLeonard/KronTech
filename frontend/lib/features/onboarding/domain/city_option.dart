class CityOption {
  const CityOption({required this.name});

  final String name;

  @override
  bool operator ==(Object other) {
    return other is CityOption && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
