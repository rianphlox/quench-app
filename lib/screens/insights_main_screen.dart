import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../constants/app_constants.dart';
import 'insights_screen.dart';

class InsightsMainScreen extends StatelessWidget {
  const InsightsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isDark = provider.settings.darkMode;

        return Theme(
          data: Theme.of(context).copyWith(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
          ),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: isDark
                  ? AppColors.primaryBlue.withOpacity(0.9)
                  : Colors.white.withOpacity(0.8),
              title: Text(
                'Insights',
                style: TextStyle(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: InsightsScreen(provider: provider),
          ),
        );
      },
    );
  }
}