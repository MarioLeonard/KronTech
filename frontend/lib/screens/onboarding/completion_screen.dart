import 'package:flutter/material.dart';
import '../../models/user_model.dart';

part 'info_row.dart';

class OnboardingCompletionScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onContinue;

  const OnboardingCompletionScreen({
    super.key,
    required this.user,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Your onboarding is complete. Here\'s your profile summary:',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow('Name', user.fullName),
                      const Divider(height: 24),
                      _InfoRow('Email', user.email),
                      const Divider(height: 24),
                      _InfoRow('Age', '${user.age} years old'),
                      const Divider(height: 24),
                      _InfoRow('Gen', user.gender),
                      const Divider(height: 24),
                      _InfoRow('Location', user.completeAddress),
                      const Divider(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interests',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 8),
                          user.interests.isNotEmpty
                              ? Wrap(
                                  spacing: 8,
                                  children: user.interests
                                      .map(
                                        (interest) => Chip(
                                          label: Text(interest),
                                          backgroundColor: Colors.blue.shade100,
                                          labelStyle: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : Text(
                                  'No interests selected',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(
                            user.enableNotifications
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            size: 20,
                            color: user.enableNotifications
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Notifications ${user.enableNotifications ? 'Enabled' : 'Disabled'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue to App',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
