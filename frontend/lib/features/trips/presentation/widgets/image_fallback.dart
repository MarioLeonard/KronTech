part of 'trip_summary_card.dart';

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.3),
            colorScheme.tertiary.withValues(alpha: 0.24),
            const Color(0xFF063970),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.travel_explore_rounded,
          color: Colors.white,
          size: 72,
        ),
      ),
    );
  }
}

String _money(num value, String currency) {
  if (value == 0) {
    return 'estimate unavailable';
  }
  return '${_number(value)} $currency';
}

String _number(num value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
