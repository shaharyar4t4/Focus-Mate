import 'package:flutter/material.dart';

class SplashController extends ChangeNotifier {
  void startTimer(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to Onboarding or Login based on logic
      // For now, let's assume it goes to Home or Container as defined in main.dart
      // Since Onboarding is not yet implemented, we can use a placeholder or route
      // Navigator.pushReplacementNamed(context, AppRoutes.onboarding);

      // Let's use a simple print for now if the route isn't fully ready,
      // but I'll set it up to navigate to splash for now or whatever is next.
      // Actually, I'll just leave it ready for navigation.
    });
  }
}
