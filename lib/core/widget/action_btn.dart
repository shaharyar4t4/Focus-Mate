import 'package:flutter/material.dart';

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const PrimaryActionButton({Key? key, required this.text, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: colors.onPrimary, size: 28),
          ],
        ),
      ),
    );
  }
}
