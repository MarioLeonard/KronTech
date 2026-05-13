import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Rich Ocean Blue layer
        Positioned.fill(
          child: Container(
            color: const Color(0xFF063970), // Richer, deeper ocean blue
          ),
        ),

        // 2. Top-Right Glowing Orb (Tropical Water / Turquoise)
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00E5FF).withValues(alpha: 0.3), // Vibrant Turquoise
                  const Color(0xFF00E5FF).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),

        // 3. Bottom-Left Glowing Orb (Sunset Coral / Golden Orange)
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF7E5F).withValues(alpha: 0.2), // Warm Sunset Coral
                  const Color(0xFFFF7E5F).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),

        // 4. Subtle Center Glow (Tropical Teal)
        Positioned(
          top: 200,
          left: 100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1CB5E0).withValues(alpha: 0.15), // Clear Water Blue
                  const Color(0xFF1CB5E0).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),

        // 5. The Content
        child,
      ],
    );
  }
}
