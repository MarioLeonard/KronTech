part of 'selection_cards.dart';

class InterestChips extends StatelessWidget {
  const InterestChips({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onToggle,
  });

  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final selected = selectedOptions.contains(option);
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onToggle(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: selected
                  ? theme.colorScheme.secondary.withValues(alpha: 0.18)
                  : theme.colorScheme.surface.withValues(alpha: 0.8),
              border: Border.all(color: Colors.white),
            ),
            child: Text(
              option,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
