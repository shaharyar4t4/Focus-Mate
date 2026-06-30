import 'package:flutter/material.dart';

class HorizontalPadding extends StatelessWidget {
  final Widget child;

  const HorizontalPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: child,
    );
  }
}
