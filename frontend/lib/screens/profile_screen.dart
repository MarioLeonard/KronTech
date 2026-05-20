import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/models/auth_exception.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/models/user_profile.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/backend_api_service.dart';
import 'package:frontend/utils/profile_date_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

part 'profile/profile_edit_widgets.dart';
part 'profile/cupertino_picker_shell.dart';
part 'profile/picker_scroll_behavior.dart';
part 'profile/profile_screen_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.user, super.key});

  final AuthUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
