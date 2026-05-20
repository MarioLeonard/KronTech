part of 'city_location_field.dart';

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
