import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/features/onboarding/presentation/widgets/profile_photo_picker_card.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _photoDataUrl = '';

  @override
  void initState() {
    super.initState();
    _loadFromProfile(widget.user.profile);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.profile != widget.user.profile && !_isEditing) {
      _loadFromProfile(widget.user.profile);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _loadFromProfile(UserProfile? profile) {
    _firstNameController.text = profile?.firstName ?? '';
    _lastNameController.text = profile?.lastName ?? '';
    _emailController.text = profile?.email ?? widget.user.email ?? '';
    _genderController.text = profile?.gender ?? '';
    _countryController.text = profile?.country ?? '';
    _cityController.text = profile?.city ?? '';
    _streetController.text = profile?.street ?? '';
    _photoDataUrl = '';
  }

  Future<void> _saveChanges() async {
    setState(() {
      _errorMessage = null;
    });

    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Name and email are required.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final profile =
        widget.user.profile ??
        UserProfile(uid: widget.user.id, email: widget.user.email);

    final updatedProfile = profile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      displayName:
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
              .trim(),
      email: _emailController.text.trim(),
      gender: _genderController.text.trim(),
      country: _countryController.text.trim(),
      city: _cityController.text.trim(),
      street: _streetController.text.trim(),
      photoUrl: _photoDataUrl.isNotEmpty ? _photoDataUrl : profile.photoUrl,
    );

    if (mounted) {
      context.read<AuthProvider>().updateProfile(updatedProfile);
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved locally. Backend update pending.')),
      );
    }
  }

  void _cancelEditing() {
    _loadFromProfile(widget.user.profile);
    setState(() {
      _isEditing = false;
      _errorMessage = null;
    });
  }

  String _formatDateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '—';
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    return '$day-$month-$year';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.user.profile;
    final displayName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (widget.user.displayName ?? 'Traveler');
    final photoUrl = profile?.photoUrl ?? widget.user.effectivePhotoUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing)
                    ProfilePhotoPickerCard(
                      value: _photoDataUrl,
                      fallbackPhotoUrl: photoUrl,
                      onChanged: (value) {
                        setState(() {
                          _photoDataUrl = value;
                        });
                      },
                    )
                  else
                    Row(
                      children: [
                        AppAvatar(
                          radius: 36,
                          imageUrl: photoUrl,
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(widget.user.email ?? 'No email'),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (_isEditing) ...[
                    _buildField(_firstNameController, 'First name'),
                    const SizedBox(height: 12),
                    _buildField(_lastNameController, 'Last name'),
                    const SizedBox(height: 12),
                    _buildField(_emailController, 'Email'),
                    const SizedBox(height: 12),
                    _buildField(_genderController, 'Gender'),
                    const SizedBox(height: 12),
                    _buildField(_countryController, 'Country'),
                    const SizedBox(height: 12),
                    _buildField(_cityController, 'City'),
                    const SizedBox(height: 12),
                    _buildField(_streetController, 'Street'),
                    if (profile?.dateOfBirth != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Date of birth: ${_formatDateOfBirth(profile!.dateOfBirth)}',
                      ),
                    ],
                  ] else ...[
                    _buildReadOnlyRow('Gender', profile?.gender),
                    _buildReadOnlyRow('Country', profile?.country),
                    _buildReadOnlyRow('City', profile?.city),
                    _buildReadOnlyRow('Street', profile?.street),
                    _buildReadOnlyRow(
                      'Date of birth',
                      _formatDateOfBirth(profile?.dateOfBirth),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : _cancelEditing,
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _isSaving ? null : _saveChanges,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Save changes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildReadOnlyRow(String label, String? value) {
    final displayValue = (value == null || value.trim().isEmpty) ? '—' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(displayValue)),
        ],
      ),
    );
  }
}
