part of '../profile_screen.dart';

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final BackendApiService _backendApiService = BackendApiService();
  late TextEditingController _genderController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _streetController;
  late TextEditingController _birthDateController;
  bool _isUploadingPhoto = false;
  bool _isEditingProfile = false;
  Uint8List? _pendingProfilePhotoBytes;

  @override
  void initState() {
    super.initState();
    final profile = widget.user.profile;
    _genderController = TextEditingController(text: profile?.gender ?? '');
    _countryController = TextEditingController(text: profile?.country ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _streetController = TextEditingController(text: profile?.street ?? '');
    _birthDateController = TextEditingController(
      text: formatProfileBirthDateInput(profile?.dateOfBirth),
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

  void _resetForm() {
    final user = context.read<AuthProvider>().user ?? widget.user;
    final profile = user.profile;
    setState(() {
      _genderController.text = profile?.gender ?? '';
      _countryController.text = profile?.country ?? '';
      _cityController.text = profile?.city ?? '';
      _streetController.text = profile?.street ?? '';
      _birthDateController.text = formatProfileBirthDateInput(
        profile?.dateOfBirth,
      );
      _isEditingProfile = false;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveProfile() async {
    final user = context.read<AuthProvider>().user ?? widget.user;
    final profile =
        user.profile ?? UserProfile(uid: user.id, email: user.email);

    String? isoDate = profile.dateOfBirth;
    if (_birthDateController.text.isNotEmpty) {
      final parsedDate = parseProfileDisplayDate(_birthDateController.text);
      if (parsedDate != null) {
        isoDate = parsedDate.toIso8601String();
      }
    }

    final updatedProfile = profile.copyWith(
      gender: _genderController.text,
      country: _countryController.text,
      city: _cityController.text,
      street: _streetController.text,
      dateOfBirth: isoDate,
    );

    context.read<AuthProvider>().updateProfile(updatedProfile);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isEditingProfile = false);
    _showSuccessSnackBar(context);
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    if (_isUploadingPhoto) {
      return;
    }

    final user = context.read<AuthProvider>().user ?? widget.user;
    if (user.idToken.isEmpty) {
      _showErrorSnackBar('Your session expired. Please sign in again.');
      return;
    }

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 84,
      );
      if (image == null) {
        return;
      }

      if (mounted) {
        setState(() {
          _isUploadingPhoto = true;
          _pendingProfilePhotoBytes = null;
        });
      }

      final bytes = await image.readAsBytes();
      if (mounted) {
        setState(() => _pendingProfilePhotoBytes = bytes);
      }

      final updatedProfile = await _backendApiService.uploadProfilePhoto(
        idToken: user.idToken,
        bytes: bytes,
        filename: image.name,
        contentType: image.mimeType ?? _mimeTypeFromName(image.name),
      );

      if (!mounted) {
        return;
      }

      context.read<AuthProvider>().updateProfile(updatedProfile);
      _showSuccessSnackBar(context, message: 'Profile photo updated!');
    } on AuthException catch (error) {
      if (mounted) {
        _showErrorSnackBar(error.message);
      }
    } catch (error) {
      debugPrint('Failed to upload profile photo: $error');
      if (mounted) {
        _showErrorSnackBar('Could not upload the profile photo.');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _showSuccessSnackBar(
    BuildContext context, {
    String message = 'Profile updated successfully!',
  }) {
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
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(message),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime(2000);
    if (_birthDateController.text.isNotEmpty) {
      initial = parseProfileDisplayDate(_birthDateController.text) ?? initial;
    }

    final DateTime? picked = await _showCupertinoDatePicker(
      context: context,
      initialDate: initial,
      minimumDate: DateTime(1900),
      maximumDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = formatProfileDisplayDate(picked);
      });
    }
  }

  Future<DateTime?> _showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime minimumDate,
    required DateTime maximumDate,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    var selectedDate = initialDate;

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _CupertinoPickerShell(
              onDone: () => Navigator.of(context).pop(selectedDate),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Brightness.dark,
                  primaryColor: colorScheme.primary,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: theme.textTheme.titleLarge
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                child: ScrollConfiguration(
                  behavior: const _PickerScrollBehavior(),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    minimumDate: minimumDate,
                    maximumDate: maximumDate,
                    onDateTimeChanged: (value) {
                      selectedDate = DateTime(
                        value.year,
                        value.month,
                        value.day,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickGender() async {
    final gender = await _showCupertinoTextPicker(
      title: 'Gender',
      values: const ['Male', 'Female', 'Other'],
      currentValue: _genderController.text,
    );
    if (gender == null) {
      return;
    }
    setState(() => _genderController.text = gender);
  }

  Future<String?> _showCupertinoTextPicker({
    required String title,
    required List<String> values,
    required String currentValue,
  }) {
    final selectedIndex = values.indexWhere(
      (value) => value.toLowerCase() == currentValue.toLowerCase(),
    );
    var selectedValue = values[selectedIndex < 0 ? 0 : selectedIndex];

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _CupertinoPickerShell(
              title: title,
              onDone: () => Navigator.of(context).pop(selectedValue),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    pickerTextStyle: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex < 0 ? 0 : selectedIndex,
                  ),
                  itemExtent: 42,
                  onSelectedItemChanged: (index) {
                    selectedValue = values[index];
                  },
                  children: [
                    for (final value in values)
                      Center(
                        child: Text(
                          value,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickCountry() async {
    final countries =
        CountryService()
            .getAll()
            .map((country) => country.name)
            .toSet()
            .toList()
          ..sort();
    final country = await _showCupertinoTextPicker(
      title: 'Country',
      values: countries,
      currentValue: _countryController.text,
    );
    if (country == null) {
      return;
    }
    setState(() {
      if (_countryController.text != country) {
        _cityController.clear();
      }
      _countryController.text = country;
    });
  }

  Future<void> _pickCity() async {
    final countryCode = _countryCodeFor(_countryController.text);
    if (countryCode.isEmpty) {
      _showErrorSnackBar('Choose a country first.');
      return;
    }

    final cities = (await csc.getCountryCities(
      countryCode,
    )).map((city) => city.name).toSet().toList()..sort();
    if (!mounted) {
      return;
    }
    if (cities.isEmpty) {
      _showErrorSnackBar('No cities found for this country.');
      return;
    }

    final city = await _showCupertinoTextPicker(
      title: 'City',
      values: cities,
      currentValue: _cityController.text,
    );
    if (city == null) {
      return;
    }
    setState(() => _cityController.text = city);
  }

  String _countryCodeFor(String countryName) {
    final normalized = countryName.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }

    for (final country in CountryService().getAll()) {
      if (country.name.toLowerCase() == normalized) {
        return country.countryCode;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<AuthProvider>().user ?? widget.user;
    final profile = user.profile;
    final displayName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (user.displayName ?? 'Traveler');
    final photoUrl = user.effectivePhotoUrl;

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROFILE',
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your travel profile, neatly tuned.',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      'Keep your personal details, location, and profile photo ready for smoother trip planning.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 4,
                    width: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GlassContainer(
                    color: const Color(0xFF0E5A90),
                    opacity: 0.18,
                    blur: 18,
                    borderRadius: 26,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 760;
                          final avatar = GestureDetector(
                            onTap: _isUploadingPhoto
                                ? null
                                : _pickAndUploadProfilePhoto,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.28,
                                        ),
                                        blurRadius: 28,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: AppAvatar(
                                    radius: isWide ? 58 : 48,
                                    imageUrl: photoUrl,
                                    imageBytes: _pendingProfilePhotoBytes,
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: colorScheme.tertiary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.24,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: _isUploadingPhoto
                                      ? const SizedBox(
                                          width: 17,
                                          height: 17,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                ),
                              ],
                            ),
                          );
                          final copy = Column(
                            crossAxisAlignment: isWide
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              Text(
                                displayName,
                                textAlign: isWide
                                    ? TextAlign.start
                                    : TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user.email ?? 'No email',
                                textAlign: isWide
                                    ? TextAlign.start
                                    : TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.64),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                          final signOut = OutlinedButton.icon(
                            onPressed: () =>
                                context.read<AuthProvider>().signOut(),
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Sign out'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          );

                          if (!isWide) {
                            return Column(
                              children: [
                                avatar,
                                const SizedBox(height: 16),
                                copy,
                                const SizedBox(height: 18),
                                signOut,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              avatar,
                              const SizedBox(width: 22),
                              Expanded(child: copy),
                              const SizedBox(width: 16),
                              signOut,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassContainer(
                    color: Colors.white,
                    opacity: 0.055,
                    blur: 16,
                    borderRadius: 24,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Personal details',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: _isEditingProfile
                                    ? 'Editing enabled'
                                    : 'Edit profile',
                                onPressed: _isEditingProfile
                                    ? null
                                    : () => setState(
                                        () => _isEditingProfile = true,
                                      ),
                                icon: const Icon(Icons.more_horiz_rounded),
                                color: Colors.white,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: _isEditingProfile ? 0.06 : 0.1,
                                  ),
                                  disabledForegroundColor: Colors.white
                                      .withValues(alpha: 0.38),
                                ),
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topLeft,
                            child: _isEditingProfile
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Edit mode is on.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.56,
                                            ),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 720;
                              final rows = [
                                InlineEditRow(
                                  label: 'Gender',
                                  icon: Icons.wc_rounded,
                                  controller: _genderController,
                                  enabled: _isEditingProfile,
                                  readOnly: true,
                                  onTap: _isEditingProfile ? _pickGender : null,
                                ),
                                InlineEditRow(
                                  label: 'Country',
                                  icon: Icons.public_rounded,
                                  controller: _countryController,
                                  enabled: _isEditingProfile,
                                  readOnly: true,
                                  onTap: _isEditingProfile
                                      ? _pickCountry
                                      : null,
                                ),
                                InlineEditRow(
                                  label: 'City',
                                  icon: Icons.location_city_rounded,
                                  controller: _cityController,
                                  enabled: _isEditingProfile,
                                  readOnly: true,
                                  onTap: _isEditingProfile ? _pickCity : null,
                                ),
                                InlineEditRow(
                                  label: 'Street',
                                  icon: Icons.signpost_rounded,
                                  controller: _streetController,
                                  enabled: _isEditingProfile,
                                  readOnly: !_isEditingProfile,
                                ),
                                InlineEditRow(
                                  label: 'Birth date',
                                  icon: Icons.cake_rounded,
                                  controller: _birthDateController,
                                  enabled: _isEditingProfile,
                                  readOnly: true,
                                  onTap: _isEditingProfile ? _pickDate : null,
                                ),
                              ];

                              if (!isWide) {
                                return Column(
                                  children: [
                                    for (final row in rows) ...[
                                      row,
                                      if (row != rows.last)
                                        const SizedBox(height: 10),
                                    ],
                                  ],
                                );
                              }

                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  for (final row in rows)
                                    SizedBox(
                                      width: (constraints.maxWidth - 12) / 2,
                                      child: row,
                                    ),
                                ],
                              );
                            },
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            child: _isEditingProfile
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 22),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: _resetForm,
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.72,
                                              ),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        FilledButton.icon(
                                          onPressed: _saveProfile,
                                          icon: const Icon(Icons.check_rounded),
                                          label: const Text(
                                            'Save changes',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                colorScheme.tertiary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 22,
                                              vertical: 15,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
