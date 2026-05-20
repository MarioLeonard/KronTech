import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/components/social_auth_button.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

part 'login/login_screen_widgets.dart';
part 'login/login_screen_animation_widgets.dart';
part 'login/login_screen_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
