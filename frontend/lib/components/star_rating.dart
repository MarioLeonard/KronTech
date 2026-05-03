import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.max = 5});

  final double rating;
  final int max;

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, size: 16, color: Colors.amber);
        }
        if (index == fullStars && hasHalf) {
          return const Icon(Icons.star_half, size: 16, color: Colors.amber);
        }
        return const Icon(Icons.star_border, size: 16, color: Colors.amber);
      }),
    );
  }
}
