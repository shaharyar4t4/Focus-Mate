import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focusmate/core/constants/app_prefs.dart';
import 'package:focusmate/core/routes/app_routes.dart';
import 'package:focusmate/core/services/permission_service.dart';

class SplashController extends ChangeNotifier {
  /// Guards against navigating twice — both the auto timer and the "Start"
  /// button route through [decideNextScreen], so the first one to run wins.
  bool _navigated = false;

  /// Auto-advance after a short splash delay.
  void startTimer(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!context.mounted) return;
      decideNextScreen(context);
    });
  }

  /// Routes to the correct screen based on saved state:
  /// - first launch -> onboarding
  /// - returning user with all permissions -> dashboard
  /// - returning user missing a permission -> permissions setup
  Future<void> decideNextScreen(BuildContext context) async {
    if (_navigated) return;
    _navigated = true;

    final prefs = await SharedPreferences.getInstance();
    final bool onboardingDone = prefs.getBool(AppPrefs.onboardingDone) ?? false;

    if (!context.mounted) return;
    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboading);
      return;
    }

    final bool granted = await PermissionService.allGranted();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      granted ? AppRoutes.dashboard : AppRoutes.permissions,
    );
  }
}
