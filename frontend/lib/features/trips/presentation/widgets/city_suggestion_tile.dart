part of 'city_multi_select_field.dart';

class _CitySuggestionTile extends StatelessWidget {
  const _CitySuggestionTile({
    required this.city,
    required this.isLast,
    required this.onTap,
  });

  final csc.City city;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: const Icon(
          Icons.location_on_outlined,
          color: Colors.white,
          size: 18,
        ),
        title: Text(
          city.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          city.countryCode,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.54),
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        onTap: onTap,
      ),
    );
  }
}
