import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/onboarding/presentation/widgets/onboarding_progress_header.dart';

void main() {
  testWidgets('progress header shows current step details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OnboardingProgressHeader(
            currentStep: 2,
            totalSteps: 5,
            title: 'Profile details',
          ),
        ),
      ),
    );

    expect(find.text('Step 3 of 5'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Profile details'), findsOneWidget);
  });
}
