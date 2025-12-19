import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.lightBlue.withAlpha((255 * 0.3).round())
            : const Color(0xFF06b6d4).withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFF06b6d4).withAlpha((255 * 0.3).round()),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '💧',
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(width: 6.0),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : const Color(0xFF06b6d4),
            ),
          ),
        ],
      ),
    );
  }
}