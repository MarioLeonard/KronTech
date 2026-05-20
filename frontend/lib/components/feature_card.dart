import 'dart:ui';
import 'package:flutter/material.dart';

part 'feature_card_state.dart';

class FeatureCard extends StatefulWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;
  final IconData icon;
  final String? imagePath;
  final IconData? buttonIcon;

  const FeatureCard({
    required this.title,
    required this.buttonText,
    required this.onPressed,
    required this.icon,
    this.imagePath,
    this.buttonIcon,
    super.key,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}
