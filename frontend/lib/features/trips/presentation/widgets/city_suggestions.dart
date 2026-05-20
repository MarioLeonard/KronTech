part of 'city_multi_select_field.dart';

class _CitySuggestions extends StatelessWidget {
  const _CitySuggestions({
    required this.cities,
    required this.isLoading,
    required this.onSelected,
  });

  final List<csc.City> cities;
  final bool isLoading;
  final ValueChanged<csc.City> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF063970).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: isLoading
              ? const Padding(
                  key: ValueKey('loading'),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : cities.isEmpty
              ? Padding(
                  key: const ValueKey('empty'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Text(
                    'No matching cities',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Column(
                  key: ValueKey('results-${cities.length}'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0; index < cities.length; index++)
                      _CitySuggestionTile(
                        city: cities[index],
                        isLast: index == cities.length - 1,
                        onTap: () => onSelected(cities[index]),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
