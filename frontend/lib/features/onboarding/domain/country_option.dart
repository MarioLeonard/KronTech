class CountryOption {
  const CountryOption({required this.name, this.code});

  final String name;
  final String? code;

  @override
  bool operator ==(Object other) {
    return other is CountryOption && other.name == name && other.code == code;
  }

  @override
  int get hashCode => Object.hash(name, code);
}
