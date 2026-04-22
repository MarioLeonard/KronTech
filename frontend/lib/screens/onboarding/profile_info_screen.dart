import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../components/form_field.dart';
import '../../components/date_picker.dart';
import '../../components/gender_selector.dart';

class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final profileData = provider.onboardingData.profileInfo;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: provider.profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Let us know a bit more about you.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            CustomFormField(
              label: 'First Name',
              initialValue: profileData.firstName,
              hint: 'Enter your first name',
              onChanged: provider.updateFirstName,
              validator: (val) =>
                  val == null || val.isEmpty ? 'First name is required' : null,
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'Last Name',
              initialValue: profileData.lastName,
              hint: 'Enter your last name',
              onChanged: provider.updateLastName,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Last name is required' : null,
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'Email',
              initialValue: profileData.email,
              hint: 'Enter your email address',
              keyboardType: TextInputType.emailAddress,
              onChanged: provider.updateEmail,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Email is required';
                if (!val.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomDatePicker(
              label: 'Date of Birth',
              initialDate: profileData.dateOfBirth,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onChanged: provider.updateDateOfBirth,
            ),
            const SizedBox(height: 24),
            GenderSelector(
              label: 'Gender',
              initialValue: profileData.gender.isEmpty
                  ? null
                  : profileData.gender,
              onChanged: provider.updateGender,
            ),
          ],
        ),
      ),
    );
  }
}
