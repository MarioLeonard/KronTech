import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C9BFF)),
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'Initializing...',
              style: const TextStyle(color: Color(0xFFF5F7FB), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
