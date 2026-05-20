import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../components/form_field.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final prefsData = provider.onboardingData.preferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: provider.preferencesFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize your experience.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            CustomFormField(
              label: 'Interests (Comma separated)',
              initialValue: prefsData.interests.join(', '),
              hint: 'e.g. Technology, Sports, Art',
              required: false,
              onChanged: provider.updateInterests,
            ),
            const SizedBox(height: 32),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive important updates and offers.'),
              value: prefsData.enableNotifications,
              onChanged: provider.toggleNotifications,
              activeThumbColor: Colors.blue,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            FormField<bool>(
              initialValue: prefsData.acceptPrivacyPolicy,
              validator: (val) {
                if (!prefsData.acceptPrivacyPolicy) {
                  return 'You must accept the privacy policy to continue';
                }
                return null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: const Text('I accept the Privacy Policy *'),
                      value: prefsData.acceptPrivacyPolicy,
                      onChanged: (value) {
                        provider.togglePrivacyPolicy(value ?? false);
                        state.didChange(value);
                      },
                      activeColor: Colors.blue,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          state.errorText ?? '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
