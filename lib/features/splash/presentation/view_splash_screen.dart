import 'package:flutter/material.dart';
import 'package:focusmate/core/assets/app_assets_link.dart';
import 'package:focusmate/core/routes/app_routes.dart';
import 'package:focusmate/core/widget/action_btn.dart';
import 'package:focusmate/core/widget/screen_padding.dart';
import 'package:provider/provider.dart';
import '../controller/splash_controller.dart';

class ViewSplashScreen extends StatefulWidget {
  const ViewSplashScreen({super.key});

  @override
  State<ViewSplashScreen> createState() => _ViewSplashScreenState();
}

class _ViewSplashScreenState extends State<ViewSplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashController>().startTimer(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: HorizontalPadding(
          child: Column(
            children: [
              const Spacer(flex: 1),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Focus Mate',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(AppAssetsLink.mainLogo),
              ),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    letterSpacing: 1.2,
                    height: 1.5,
                    fontSize: 35,
                  ),
                  children: [
                    const TextSpan(text: 'Let’s go to pomodoro \n'),
                    TextSpan(
                      text: 'Study Time.',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: PrimaryActionButton(
                    text: 'Start',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.onboading);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
