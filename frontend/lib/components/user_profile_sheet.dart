import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/models/user_profile.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/backend_api_service.dart';
import 'package:provider/provider.dart';

Future<void> showUserProfileSheet(
  BuildContext context, {
  required String name,
  String? avatarUrl,
  String? status,
  String? email,
  String? userId,
}) {
  final idToken = context.read<AuthProvider>().user?.idToken;
  final profileFuture =
      userId != null && userId.trim().isNotEmpty && idToken != null
      ? BackendApiService().fetchUserProfile(
          idToken: idToken,
          userId: userId.trim(),
        )
      : null;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.36),
    builder: (context) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: profileFuture == null
              ? _UserProfileSheetContent(
                  name: name,
                  avatarUrl: avatarUrl,
                  status: status,
                  email: email,
                  userId: userId,
                )
              : FutureBuilder<UserProfile>(
                  future: profileFuture,
                  builder: (context, snapshot) {
                    final profile = snapshot.data;
                    final fullName = profile?.fullName;
                    return _UserProfileSheetContent(
                      name: fullName != null && fullName.isNotEmpty
                          ? fullName
                          : name,
                      avatarUrl: profile?.photoUrl ?? avatarUrl,
                      status: status,
                      email: profile?.email ?? email,
                      dateOfBirth: profile?.dateOfBirth,
                      country: profile?.country,
                      city: profile?.city,
                      isLoading:
                          snapshot.connectionState == ConnectionState.waiting,
                    );
                  },
                ),
        ),
      );
    },
  );
}

class _UserProfileSheetContent extends StatelessWidget {
  const _UserProfileSheetContent({
    required this.name,
    this.avatarUrl,
    this.status,
    this.email,
    this.userId,
    this.dateOfBirth,
    this.country,
    this.city,
    this.isLoading = false,
  });

  final String name;
  final String? avatarUrl;
  final String? status;
  final String? email;
  final String? userId;
  final String? dateOfBirth;
  final String? country;
  final String? city;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final details = [
      if (email != null && email!.trim().isNotEmpty)
        _ProfileDetail(icon: Icons.mail_outline_rounded, value: email!.trim()),
      if (_formatBirthDate(dateOfBirth) case final birthDate?)
        _ProfileDetail(icon: Icons.cake_rounded, value: birthDate),
      if (country != null && country!.trim().isNotEmpty)
        _ProfileDetail(icon: Icons.public_rounded, value: country!.trim()),
      if (city != null && city!.trim().isNotEmpty)
        _ProfileDetail(icon: Icons.location_city_rounded, value: city!.trim()),
    ];

    return GlassContainer(
      color: const Color(0xFF063970),
      opacity: 0.96,
      blur: 20,
      borderRadius: 26,
      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
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
            const SizedBox(height: 22),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                AppAvatar(
                  imageUrl: avatarUrl,
                  radius: 48,
                  icon: Icons.person_outline_rounded,
                ),
                if (isLoading)
                  SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (status != null && status!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _StatusPill(status: status!.trim()),
            ],
            if (details.isNotEmpty) ...[
              const SizedBox(height: 18),
              for (final detail in details) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(detail.icon, color: colorScheme.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            detail.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.64),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (detail != details.last) const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String? _formatBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final date = DateTime.tryParse(value);
    if (date == null) {
      return null;
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}

class _ProfileDetail {
  const _ProfileDetail({required this.icon, required this.value});

  final IconData icon;
  final String value;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isOnline = status.toLowerCase() == 'connected';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOnline ? Colors.greenAccent : Colors.white38,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
