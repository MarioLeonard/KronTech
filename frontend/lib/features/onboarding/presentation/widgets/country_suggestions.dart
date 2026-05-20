part of 'country_location_field.dart';

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
