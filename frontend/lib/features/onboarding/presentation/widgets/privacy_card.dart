import 'package:flutter/material.dart';

class PrivacyCard extends StatelessWidget {
  const PrivacyCard({
    super.key,
    required this.accepted,
    required this.onChanged,
    this.errorText,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: theme.colorScheme.surface.withValues(alpha: 0.75),
            border: Border.all(
              color: accepted
                  ? theme.colorScheme.secondary
                  : theme.dividerColor,
            ),
          ),
          child: CheckboxListTile(
            value: accepted,
            onChanged: (value) => onChanged(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'I accept the privacy policy',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              'Your information stays local in Hive storage during onboarding and is saved again on completion for verification.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: errorText == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
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
