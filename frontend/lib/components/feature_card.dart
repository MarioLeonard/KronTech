import 'dart:ui';
import 'package:flutter/material.dart';

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

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        scale: _isHovered ? 1.025 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(maxWidth: 420),
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.2),
                blurRadius: _isHovered ? 42 : 30,
                spreadRadius: _isHovered ? -2 : -5,
                offset: Offset(0, _isHovered ? 18 : 0),
              ),
              if (_isHovered)
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 34,
                  spreadRadius: -8,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(
                        0xFF0E5A90,
                      ).withValues(alpha: _isHovered ? 0.42 : 0.32),
                      const Color(
                        0xFF08B6D8,
                      ).withValues(alpha: _isHovered ? 0.2 : 0.13),
                      Colors.white.withValues(alpha: _isHovered ? 0.12 : 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: _isHovered ? 0.58 : 0.36,
                    ),
                    width: _isHovered ? 1.4 : 1.1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.05),
                        ),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          scale: _isHovered ? 1.04 : 1,
                          child: widget.imagePath != null
                              ? Image.asset(
                                  widget.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        widget.icon,
                                        size: 64,
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Icon(
                                    widget.icon,
                                    size: 64,
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: widget.onPressed,
                              icon: Icon(
                                widget.buttonIcon ??
                                    Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: Text(
                                widget.buttonText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.tertiary
                                    .withValues(
                                      alpha: _isHovered ? 0.98 : 0.84,
                                    ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
