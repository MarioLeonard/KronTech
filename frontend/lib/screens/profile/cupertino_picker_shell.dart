part of '../profile_screen.dart';

class _CupertinoPickerShell extends StatelessWidget {
  const _CupertinoPickerShell({
    required this.child,
    required this.onDone,
    this.title,
  });

  final Widget child;
  final VoidCallback onDone;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF063970),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onDone,
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            SizedBox(height: 176, child: child),
          ],
        ),
      ),
    );
  }
}
