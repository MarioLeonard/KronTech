import 'package:flutter/gestures.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: accepted,
              onChanged: (value) => onChanged(value ?? false),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodyLarge,
                    children: [
                      const TextSpan(text: 'I agree with the '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: _linkStyle(theme),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showPrivacyPolicy(context),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: _linkStyle(theme),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showTerms(context),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

  TextStyle? _linkStyle(ThemeData theme) {
    return theme.textTheme.bodyLarge?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      decoration: TextDecoration.underline,
      decorationColor: Colors.white,
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showLegalDialog(
      context,
      title: 'Privacy Policy',
      body:
          'We collect only the information needed to create your profile and complete onboarding. This includes your name, email, date of birth, selected gender, country, city, street address, and privacy confirmation.\n\n'
          'Your onboarding data is stored locally on this device for profile setup and testing. Location access is optional and is used only to prefill address fields when you choose to use it.\n\n'
          'We do not sell your personal information. You can edit or clear your profile details from the app flow where those controls are available.',
    );
  }

  void _showTerms(BuildContext context) {
    _showLegalDialog(
      context,
      title: 'Terms and Conditions',
      body:
          'By continuing, you confirm that the information you provide is accurate and that you are allowed to use this application.\n\n'
          'The app may use your entered profile details to personalize the experience and complete local onboarding. Location-based address detection is optional and depends on device permissions and third-party map data.\n\n'
          'You agree not to misuse the service, attempt to disrupt its operation, or provide information that you are not authorized to share.',
    );
  }

  void _showLegalDialog(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 240),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        final theme = Theme.of(context);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
