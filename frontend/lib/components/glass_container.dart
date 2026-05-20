import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Border? border;
  final double blur;
  final Color? color;
  final double opacity;
  final List<BoxShadow>? shadow;

  const GlassContainer({
    required this.child,
    this.borderRadius = 20,
    this.border,
    this.blur = 12.0,
    this.color,
    this.opacity = 0.15,
    this.shadow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow:
            shadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border:
                  border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
