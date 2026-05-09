import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../components/form_field.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final addressData = provider.onboardingData.address;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: provider.addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Address',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Where can we find you?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            CustomFormField(
              label: 'Country',
              initialValue: addressData.country,
              hint: 'e.g. Romania',
              onChanged: provider.updateCountry,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Country is required' : null,
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'City',
              initialValue: addressData.city,
              hint: 'e.g. Bucharest',
              onChanged: provider.updateCity,
              validator: (val) =>
                  val == null || val.isEmpty ? 'City is required' : null,
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'Street Address',
              initialValue: addressData.street,
              hint: 'Street name and number',
              onChanged: provider.updateStreet,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Street is required' : null,
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'ZIP / Postal Code',
              initialValue: addressData.zipCode,
              hint: 'e.g. 010011',
              keyboardType: TextInputType.number,
              onChanged: provider.updateZipCode,
              validator: (val) =>
                  val == null || val.isEmpty ? 'ZIP Code is required' : null,
            ),
          ],
        ),
      ),
    );
  }
}
