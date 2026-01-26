import 'package:flutter/material.dart';
import 'package:focusmate/features/onboarding/presentation/view_oboarding.dart';
import 'package:focusmate/features/splash/presentation/view_splash_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboading = '/onboading';
  // static const login = '/login';
  // static const signup = '/signup';
  // static const getstarted = '/getstarted';
  // static const group = '/group';
  // static const activities = '/activities';
  // static const accounts = '/account';
  // static const firends = '/firends';
  // static const bottomNav = '/bottomnav';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => ViewSplashScreen(),
    onboading: (context) => ViewOboarding(),
    // login: (context) => ViewLogin(),
    // signup: (context) => ViewSignup(),
    // getstarted: (context) => ViewGetStarted(),
    // group: (context) => ViewGroup(),
    // activities: (context) => ViewActivities(),
    // firends: (context) => ViewFriends(),
    // bottomNav: (context) => BottomNavigation()

    // login: (context) => ViewLogin(),
    // dashboard: (context) => ViewDashboard(),
  };
}
