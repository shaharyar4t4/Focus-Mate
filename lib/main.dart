import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/util/util.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'features/splash/controller/splash_controller.dart';
import 'features/onboarding/controller/onboarding_controller.dart';
import 'features/dashboard/controller/dashboard_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");

    MaterialTheme theme = MaterialTheme(textTheme);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Focus Mate',
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
