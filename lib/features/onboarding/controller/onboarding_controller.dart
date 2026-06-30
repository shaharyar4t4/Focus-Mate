import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/assets/app_assets_link.dart';
import '../../../core/constants/app_prefs.dart';
import '../../../core/routes/app_routes.dart';

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

  Future<void> nextPage(BuildContext context) async {
    if (_currentIndex < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Last page: remember that onboarding is done so future launches skip it.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppPrefs.onboardingDone, true);

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.permissions);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
