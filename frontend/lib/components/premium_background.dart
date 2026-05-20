import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: const Color(0xFF063970))),

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
                  const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  const Color(0xFF00E5FF).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),

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
                  const Color(0xFFFF7E5F).withValues(alpha: 0.2),
                  const Color(0xFFFF7E5F).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),

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
                  const Color(0xFF1CB5E0).withValues(alpha: 0.15),
                  const Color(0xFF1CB5E0).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),

        child,
      ],
    );
  }
}
