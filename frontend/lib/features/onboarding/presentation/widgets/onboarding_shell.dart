import 'package:flutter/material.dart';

class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.child,
    required this.footer,
    required this.header,
  });

  final Widget child;
  final Widget footer;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const Positioned(
            top: -140,
            left: -80,
            child: _AmbientGlow(
              size: 280,
              colors: [Color(0x557C9BFF), Color(0x1157D7A6)],
            ),
          ),
          const Positioned(
            bottom: -160,
            right: -40,
            child: _AmbientGlow(
              size: 320,
              colors: [Color(0x338EE3FF), Color(0x117C9BFF)],
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth > 900
                    ? 56.0
                    : 24.0;
                final cardWidth = constraints.maxWidth > 900 ? 760.0 : 680.0;

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: cardWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          header,
                          const SizedBox(height: 24),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(
                                alpha: 0.92,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                28,
                                24,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  child,
                                  const SizedBox(height: 28),
                                  footer,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ); // <-- Fixed: Properly closed the Scaffold here.
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
