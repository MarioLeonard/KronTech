part of '../main_shell.dart';

class _RailSelectionPill extends StatelessWidget {
  const _RailSelectionPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: theme.colorScheme.tertiary,
          ),
        ),
      ),
    );
  }
}
