import 'package:flutter/material.dart';
import 'package:focusmate/core/routes/app_routes.dart';

class SplashController extends ChangeNotifier {
  void startTimer(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, AppRoutes.onboading);
    });
  }
}
