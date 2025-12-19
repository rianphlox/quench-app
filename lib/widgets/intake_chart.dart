import 'package:flutter/material.dart';
import '../models/water_log.dart';
import '../constants/app_constants.dart';

class IntakeChart extends StatelessWidget {
  final List<WaterLog> logs;
  final String themeColor;

  const IntakeChart({
    super.key,
    required this.logs,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = themeColors.firstWhere(
      (color) => color.value == themeColor,
      orElse: () => themeColors.first,
    ).color;

    // Group logs by hour for today
    final today = DateTime.now();
    final todayLogs = logs.where((log) {
      return log.timestamp.year == today.year &&
             log.timestamp.month == today.month &&
             log.timestamp.day == today.day;
    }).toList();

    // Create hourly data
    final hourlyData = <int, double>{};
    for (int i = 0; i < 24; i++) {
      hourlyData[i] = 0.0;
    }

    for (final log in todayLogs) {
      final hour = log.timestamp.hour;
      hourlyData[hour] = (hourlyData[hour] ?? 0) + log.volume;
    }

    final maxVolume = hourlyData.values.isEmpty
        ? 1.0
        : hourlyData.values.reduce((a, b) => a > b ? a : b);
    final normalizedMax = maxVolume == 0 ? 1.0 : maxVolume;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Intake Pattern',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(24, (index) {
              final volume = hourlyData[index] ?? 0;
              final height = normalizedMax > 0 ? (volume / normalizedMax) * 100 : 0.0;
              final isCurrentHour = index == DateTime.now().hour;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (volume > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${volume.toInt()}',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textDark.withAlpha((255 * 0.8).round())
                                  : AppColors.textLight.withAlpha((255 * 0.8).round()),
                            ),
                          ),
                        ),
                      Container(
                        height: height.clamp(2.0, 100.0),
                        decoration: BoxDecoration(
                          color: isCurrentHour
                              ? primaryColor
                              : primaryColor.withAlpha((255 * 0.7).round()),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        index % 6 == 0 ? '$index' : '',
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark
                              ? AppColors.textDark.withAlpha((255 * 0.6).round())
                              : AppColors.textLight.withAlpha((255 * 0.6).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        if (todayLogs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Peak hour: ${_getPeakHour(hourlyData)}h (${hourlyData.values.reduce((a, b) => a > b ? a : b).toInt()}ml)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textDark.withAlpha((255 * 0.8).round())
                      : AppColors.textLight.withAlpha((255 * 0.8).round()),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  int _getPeakHour(Map<int, double> hourlyData) {
    double maxVolume = 0;
    int peakHour = 0;

    hourlyData.forEach((hour, volume) {
      if (volume > maxVolume) {
        maxVolume = volume;
        peakHour = hour;
      }
    });

    return peakHour;
  }
}