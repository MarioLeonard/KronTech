part of '../profile_screen.dart';

class InlineEditRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool? enabled;
  final bool readOnly;
  final VoidCallback? onTap;

  const InlineEditRow({
    required this.label,
    required this.icon,
    required this.controller,
    required this.enabled,
    this.readOnly = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = enabled ?? false;
    final effectiveReadOnly = readOnly || !isEnabled;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isEnabled ? 0.075 : 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: isEnabled ? 0.11 : 0.07),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 17, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              readOnly: effectiveReadOnly,
              onTap: isEnabled ? onTap : null,
              cursorColor: Colors.white,
              style: TextStyle(
                color: Colors.white.withValues(alpha: isEnabled ? 1 : 0.62),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white.withValues(
                  alpha: isEnabled ? 0.07 : 0.04,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                hintText: 'Not set',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.34),
                  fontWeight: FontWeight.w600,
                ),
                suffixIcon: isEnabled && readOnly
                    ? Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.54),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.72),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
