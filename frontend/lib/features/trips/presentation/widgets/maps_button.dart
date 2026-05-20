part of 'restaurant_card.dart';

class _MapsButton extends StatelessWidget {
  const _MapsButton({required this.option});

  final DiningOption option;

  @override
  Widget build(BuildContext context) {
    final query = [
      option.name,
      if (option.area.isNotEmpty && option.area != 'Area unspecified')
        option.area,
      if (option.city.isNotEmpty && option.city != 'City unspecified')
        option.city,
    ].join(' ');

    return Tooltip(
      message: 'Open in Google Maps',
      child: Semantics(
        button: true,
        label: 'Open ${option.name} in Google Maps',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openMaps(query),
            child: Container(
              height: 46,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A73E8).withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, color: Colors.white, size: 19),
                  SizedBox(width: 8),
                  Text(
                    'Open Maps',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatMeal(String value) {
  final normalized = value.trim().replaceAll('_', ' ');
  if (normalized.isEmpty) {
    return 'Meal';
  }
  return normalized[0].toUpperCase() + normalized.substring(1);
}

Future<void> _openMaps(String query) async {
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': query,
  });
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String _number(num value) {
  if (value == 0) {
    return 'estimate unavailable';
  }
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
