part of 'accommodation_card.dart';

class _AccommodationMeta extends StatelessWidget {
  const _AccommodationMeta({
    required this.type,
    required this.nightlyCost,
    required this.currency,
  });

  final String type;
  final num nightlyCost;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaBadge(icon: Icons.apartment_rounded, label: _formatType(type)),
        _MetaBadge(
          icon: Icons.payments_rounded,
          label: '${_number(nightlyCost)} $currency/night',
        ),
      ],
    );
  }
}
