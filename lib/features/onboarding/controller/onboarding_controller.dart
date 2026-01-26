import 'package:flutter/material.dart';
import '../../../core/assets/app_assets_link.dart';

class OnboardingController extends ChangeNotifier {
  final PageController pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': AppAssetsLink.onboarding1,
      'title': 'Stay Focused, Achieve More',
      'desc': 'Organize tasks and boost productivity with Focus Mate.',
    },
    {
      'image': AppAssetsLink.onboarding2,
      'title': 'Track Your Progress',
      'desc':
          'Track daily achievements and stay motivated with detailed stats.',
    },
  ];

  int get currentIndex => _currentIndex;

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void nextPage(BuildContext context) {
    if (_currentIndex < 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Login/Dashboard
      // Navigator.pushNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
