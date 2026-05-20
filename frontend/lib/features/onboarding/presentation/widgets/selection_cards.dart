import 'package:flutter/material.dart';

part 'interest_chips.dart';

class SelectionCardGroup extends StatelessWidget {
  const SelectionCardGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.errorText,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: options.map((option) {
            final isSelected = option == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.18)
                        : theme.colorScheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                key: ValueKey(option),
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.circle_outlined,
                                key: ValueKey('${option}_empty'),
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: errorText == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
