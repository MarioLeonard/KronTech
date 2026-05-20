import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../components/buttons.dart';
import 'profile_info_screen.dart';
import 'address_screen.dart';
import 'preferences_screen.dart';
import 'completion_screen.dart';

part 'main_onboarding_screen_state.dart';

class MainOnboardingScreen extends StatefulWidget {
  const MainOnboardingScreen({super.key});

  @override
  State<MainOnboardingScreen> createState() => _MainOnboardingScreenState();
}
