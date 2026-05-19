import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/features/onboarding/presentation/widgets/city_location_field.dart';
import 'package:frontend/features/onboarding/presentation/widgets/country_location_field.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/models/user_profile.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.user, super.key});

  final AuthUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _genderController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _streetController;
  late TextEditingController _birthDateController;

  @override
  void initState() {
    super.initState();
    final profile = widget.user.profile;
    _genderController = TextEditingController(text: profile?.gender ?? '');
    _countryController = TextEditingController(text: profile?.country ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _streetController = TextEditingController(text: profile?.street ?? '');
    _birthDateController = TextEditingController(
      text: _formatDateStr(profile?.dateOfBirth),
    );
  }

  @override
  void dispose() {
    _genderController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String _formatDateStr(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  void _resetForm() {
    final profile = widget.user.profile;
    setState(() {
      _genderController.text = profile?.gender ?? '';
      _countryController.text = profile?.country ?? '';
      _cityController.text = profile?.city ?? '';
      _streetController.text = profile?.street ?? '';
      _birthDateController.text = _formatDateStr(profile?.dateOfBirth);
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveProfile() async {
    final profile =
        widget.user.profile ??
        UserProfile(uid: widget.user.id, email: widget.user.email);

    // Parse back the date if possible
    String? isoDate = profile.dateOfBirth;
    if (_birthDateController.text.isNotEmpty) {
      final parts = _birthDateController.text.split('-');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          isoDate = DateTime(year, month, day).toIso8601String();
        }
      }
    }

    final updatedProfile = profile.copyWith(
      gender: _genderController.text,
      country: _countryController.text,
      city: _cityController.text,
      street: _streetController.text,
      dateOfBirth: isoDate,
    );

    // Wait for the save operation to complete
    context.read<AuthProvider>().updateProfile(updatedProfile);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    FocusScope.of(context).unfocus();

    if (mounted) {
      _showSuccessSnackBar(context);
    }
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: GlassContainer(
          color: const Color(0xFF063970),
          opacity: 0.9,
          blur: 12,
          borderRadius: 16,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.greenAccent,
                  size: 28,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Profile updated successfully!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime(2000);
    if (_birthDateController.text.isNotEmpty) {
      final parts = _birthDateController.text.split('-');
      if (parts.length == 3) {
        initial =
            DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}') ?? initial;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.orange.shade600,
              onPrimary: Colors.white,
              surface: const Color(0xFF063970),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  void _pickGender() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF063970),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Male', 'Female', 'Other'].map((gender) {
              return ListTile(
                title: Text(
                  gender,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _genderController.text = gender;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _pickCountry() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
              child: GlassContainer(
                color: const Color(0xFF0A4275),
                opacity: 0.8,
                blur: 12,
                borderRadius: 24,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Country',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: CountryLocationField(
                          value: _countryController.text,
                          onChanged: (value) async {
                            if (value.isNotEmpty) {
                              setState(() => _countryController.text = value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _pickCity() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
              child: GlassContainer(
                color: const Color(0xFF0A4275),
                opacity: 0.8,
                blur: 12,
                borderRadius: 24,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select City',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: CityLocationField(
                          value: _cityController.text,
                          country: _countryController.text,
                          onChanged: (value) async {
                            if (value.isNotEmpty) {
                              setState(() => _cityController.text = value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.user.profile;
    final displayName =
        profile?.fullName.isNotEmpty == true
            ? profile!.fullName
            : (widget.user.displayName ?? 'Traveler');
    final photoUrl = profile?.photoUrl ?? widget.user.effectivePhotoUrl;

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => debugPrint('Open image picker'),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: AppAvatar(
                              radius: 60,
                              imageUrl: photoUrl,
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.email ?? 'No email',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Details Glass Container
              GlassContainer(
                color: Colors.white,
                opacity: 0.05,
                blur: 16,
                borderRadius: 24,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      InlineEditRow(
                        label: 'Gender',
                        controller: _genderController,
                        readOnly: true,
                        onTap: _pickGender,
                      ),
                      _buildDivider(),
                      InlineEditRow(
                        label: 'Country',
                        controller: _countryController,
                        readOnly: true,
                        onTap: _pickCountry,
                      ),
                      _buildDivider(),
                      InlineEditRow(
                        label: 'City',
                        controller: _cityController,
                        readOnly: true,
                        onTap: _pickCity,
                      ),
                      _buildDivider(),
                      InlineEditRow(
                        label: 'Street',
                        controller: _streetController,
                      ),
                      _buildDivider(),
                      InlineEditRow(
                        label: 'Birth Date',
                        controller: _birthDateController,
                        readOnly: true,
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 32),
                      // 2. Save & Cancel Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _resetForm,
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.1),
      height: 1,
      indent: 24,
      endIndent: 24,
    );
  }
}

class InlineEditRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;

  const InlineEditRow({
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              textAlign: TextAlign.right,
              cursorColor: Colors.white,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: 'Not set',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w500,
                ),
                focusedBorder:
                    readOnly
                        ? InputBorder.none
                        : UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
