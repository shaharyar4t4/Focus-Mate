import 'package:flutter/material.dart';
import 'package:focusmate/features/dashboard/presentation/view_dashboard.dart';
import 'package:focusmate/features/onboarding/presentation/view_oboarding.dart';
import 'package:focusmate/features/splash/presentation/view_splash_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboading = '/onboading';
  static const dashboard = '/dashboard';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const ViewSplashScreen(),
    onboading: (context) => const ViewOboarding(),
    dashboard: (context) => const ViewDashboard(),
  };
}
