import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widget/action_btn.dart';
import '../controller/onboarding_controller.dart';
import '../../../core/widget/screen_padding.dart';

class ViewOboarding extends StatelessWidget {
  const ViewOboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.updateIndex,
              itemCount: controller.onboardingData.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  controller.onboardingData[index]['image']!,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: HorizontalPadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    controller.onboardingData[controller
                        .currentIndex]['title']!,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.onboardingData[controller.currentIndex]['desc']!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          controller.onboardingData.length,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: controller.currentIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: controller.currentIndex == index
                                  ? theme.colorScheme.primary
                                  : Colors.white30,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      PrimaryActionButton(
                        text:
                            controller.currentIndex ==
                                controller.onboardingData.length - 1
                            ? 'Get Started'
                            : 'Next',
                        onTap: () => controller.nextPage(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
