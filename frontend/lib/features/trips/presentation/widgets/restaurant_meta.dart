part of 'restaurant_card.dart';

class _RestaurantMeta extends StatelessWidget {
  const _RestaurantMeta({
    required this.cuisine,
    required this.recommendedFor,
    required this.estimatedMealCost,
    required this.currency,
  });

  final String cuisine;
  final String recommendedFor;
  final num estimatedMealCost;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaBadge(icon: Icons.restaurant_menu_rounded, label: cuisine),
        _MetaBadge(
          icon: Icons.schedule_rounded,
          label: _formatMeal(recommendedFor),
        ),
        _MetaBadge(
          icon: Icons.payments_rounded,
          label: '${_number(estimatedMealCost)} $currency/person',
        ),
      ],
    );
  }
}
