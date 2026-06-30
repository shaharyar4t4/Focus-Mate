import 'package:flutter/material.dart';
import 'package:focusmate/features/dashboard/presentation/view_dashboard.dart';
import 'package:focusmate/features/help/presentation/view_help.dart';
import 'package:focusmate/features/onboarding/presentation/view_oboarding.dart';
import 'package:focusmate/features/permissions/presentation/view_permission.dart';
import 'package:focusmate/features/splash/presentation/view_splash_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboading = '/onboading';
  static const permissions = '/permissions';
  static const dashboard = '/dashboard';
  static const help = '/help';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const ViewSplashScreen(),
    onboading: (context) => const ViewOboarding(),
    permissions: (context) => const ViewPermission(),
    dashboard: (context) => const ViewDashboard(),
    help: (context) => const ViewHelp(),
  };
}
