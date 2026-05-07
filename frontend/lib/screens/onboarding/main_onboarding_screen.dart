import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../components/buttons.dart';
import 'profile_info_screen.dart';
import 'address_screen.dart';
import 'preferences_screen.dart';
import 'completion_screen.dart';

class MainOnboardingScreen extends StatefulWidget {
  const MainOnboardingScreen({super.key});

  @override
  State<MainOnboardingScreen> createState() => _MainOnboardingScreenState();
}

class _MainOnboardingScreenState extends State<MainOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  final List<String> _stepLabels = ['Profile', 'Address', 'Preferences'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().loadSavedData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNextStep() async {
    final provider = context.read<OnboardingProvider>();

    if (provider.validateCurrentStep(_currentPage)) {
      await provider.saveProgress();

      if (_currentPage < _totalPages - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields correctly.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleFinish() async {
    final provider = context.read<OnboardingProvider>();

    // Check if user is authenticated
    if (!provider.isUserAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in with Firebase Auth first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (provider.validateCurrentStep(_currentPage)) {
      await provider.saveProgress();

      // Complete onboarding and sync to Firestore
      final userModel = await provider.completeOnboardingAndSync();

      if (!mounted) return;

      if (userModel != null) {
        // Navigate to completion screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OnboardingCompletionScreen(
              user: userModel,
              onContinue: () {
                // Navigate to home screen or next page
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Welcome to the app!')),
                );
              },
            ),
          ),
        );
      } else {
        // Show error if sync failed
        final errorMsg =
            provider.firestoreSyncError ?? 'Unknown error occurred';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<OnboardingProvider>().isLoading;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: StepProgressIndicator(
            currentStep: _currentPage,
            totalSteps: _totalPages,
            stepLabels: _stepLabels,
          ),
        ),
        toolbarHeight: 100,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  ProfileInfoScreen(),
                  AddressScreen(),
                  PreferencesScreen(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                text: _currentPage == _totalPages - 1
                    ? 'Finish Onboarding'
                    : 'Next Step',
                onPressed: _currentPage == _totalPages - 1
                    ? _handleFinish
                    : _handleNextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
