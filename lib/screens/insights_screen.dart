import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/intake_chart.dart';
import '../widgets/calendar_view.dart';

class InsightsScreen extends StatelessWidget {
  final AppProvider provider;

  const InsightsScreen({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = provider.settings.darkMode;
    final primaryColor = themeColors.firstWhere(
      (color) => color.value == provider.settings.themeColor,
      orElse: () => themeColors.first,
    ).color;

    // Filter today's logs for specific components
    final todaysLogs = provider.logs.where((log) {
      final today = DateTime.now();
      return log.timestamp.year == today.year &&
             log.timestamp.month == today.month &&
             log.timestamp.day == today.day;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Timeline Section
          _buildSectionHeader('Today\'s Timeline', isDark),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.lightBlue.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: IntakeChart(
              logs: todaysLogs,
              themeColor: provider.settings.themeColor,
            ),
          ),
          const SizedBox(height: 24),

          // Monthly Overview Section
          _buildSectionHeader('Monthly Overview', isDark),
          const SizedBox(height: 8),
          CalendarView(
            logs: provider.logs,
            dailyGoal: provider.settings.dailyGoal,
            themeColor: provider.settings.themeColor,
          ),
          const SizedBox(height: 24),

          // Achievements Section
          _buildSectionHeader('Achievements', isDark),
          const SizedBox(height: 8),
          _buildBadgeSection(isDark, primaryColor),
          const SizedBox(height: 24),

          // Today's Logs Section
          _buildSectionHeader('Today\'s Logs', isDark),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.lightBlue.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: _buildTodaysLogs(todaysLogs, isDark, primaryColor),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isDark
            ? AppColors.textDark.withOpacity(0.6)
            : AppColors.textLight.withOpacity(0.6),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildBadgeSection(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.lightBlue.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.unlockedBadges.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: availableBadges.length,
              itemBuilder: (context, index) {
                final badge = availableBadges[index];
                final isUnlocked = provider.unlockedBadges
                    .any((unlockedBadge) => unlockedBadge.id == badge.id);

                return Container(
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? primaryColor.withOpacity(0.1)
                        : (isDark
                            ? AppColors.lightBlue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUnlocked
                          ? primaryColor
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: isUnlocked ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badge.icon,
                        style: TextStyle(
                          fontSize: 24,
                          color: isUnlocked ? null : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? (isDark ? AppColors.textDark : AppColors.textLight)
                              : (isDark
                                  ? AppColors.textDark.withOpacity(0.3)
                                  : AppColors.textLight.withOpacity(0.3)),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Center(
              child: Text(
                'Start logging water to unlock badges!',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.7)
                      : AppColors.textLight.withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodaysLogs(List<dynamic> todaysLogs, bool isDark, Color primaryColor) {
    if (todaysLogs.isEmpty) {
      return Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 48,
            color: isDark
                ? AppColors.textDark.withOpacity(0.3)
                : AppColors.textLight.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No water logged today yet',
            style: TextStyle(
              color: isDark
                  ? AppColors.textDark.withOpacity(0.7)
                  : AppColors.textLight.withOpacity(0.7),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todaysLogs.length,
      itemBuilder: (context, index) {
        final log = todaysLogs.reversed.toList()[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightBlue.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${log.volume.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${log.volume.toInt()}ml Added',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(log.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textDark.withOpacity(0.7)
                            : AppColors.textLight.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  provider.removeWaterLog(log.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed ${log.volume.toInt()}ml log')),
                  );
                },
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey,
                iconSize: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}