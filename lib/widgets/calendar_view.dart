import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/water_log.dart';
import '../constants/app_constants.dart';

class CalendarView extends StatefulWidget {
  final List<WaterLog> logs;
  final double dailyGoal;
  final String themeColor;

  const CalendarView({
    super.key,
    required this.logs,
    required this.dailyGoal,
    required this.themeColor,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime currentMonth = DateTime.now();

  Map<String, double> get dailyVolumes {
    final volumes = <String, double>{};
    for (final log in widget.logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.timestamp);
      volumes[dateKey] = (volumes[dateKey] ?? 0) + log.volume;
    }
    return volumes;
  }

  List<DateTime> get daysInMonth {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    // Start from the beginning of the week containing the first day
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    // End at the end of the week containing the last day
    final endDate = lastDay.add(Duration(days: 6 - (lastDay.weekday % 7)));

    final days = <DateTime>[];
    var current = startDate;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  Color getDayColor(double volume, bool isDark) {
    final primaryColor = themeColors.firstWhere(
      (color) => color.value == widget.themeColor,
      orElse: () => themeColors.first,
    ).color;

    if (volume >= widget.dailyGoal) {
      return Colors.green;
    } else if (volume >= widget.dailyGoal * 0.5) {
      return primaryColor;
    } else if (volume > 0) {
      return Colors.orange;
    }
    return isDark ? AppColors.lightBlue.withOpacity(0.2) : Colors.grey.shade200;
  }

  bool isCurrentMonth(DateTime day) {
    return day.month == currentMonth.month && day.year == currentMonth.year;
  }

  bool isToday(DateTime day) {
    final today = DateTime.now();
    return day.year == today.year &&
           day.month == today.month &&
           day.day == today.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = themeColors.firstWhere(
      (color) => color.value == widget.themeColor,
      orElse: () => themeColors.first,
    ).color;

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
          // Header with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(currentMonth),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                      });
                    },
                    icon: const Icon(Icons.chevron_right),
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textDark.withOpacity(0.6)
                                : AppColors.textLight.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          ...List.generate((daysInMonth.length / 7).ceil(), (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final dayIndex7 = weekIndex * 7 + dayIndex;
                  if (dayIndex7 >= daysInMonth.length) {
                    return const Expanded(child: SizedBox());
                  }

                  final day = daysInMonth[dayIndex7];
                  final dateKey = DateFormat('yyyy-MM-dd').format(day);
                  final volume = dailyVolumes[dateKey] ?? 0;
                  final percentage = ((volume / widget.dailyGoal) * 100).round();
                  final dayColor = getDayColor(volume, isDark);
                  final isCurrentMonthDay = isCurrentMonth(day);
                  final isTodayDay = isToday(day);

                  return Expanded(
                    child: Tooltip(
                      message: '${DateFormat('MMM d').format(day)}: ${volume.toInt()}ml ($percentage%)',
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCurrentMonthDay ? dayColor : dayColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: isTodayDay
                              ? Border.all(color: primaryColor, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: volume > 0
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textDark.withOpacity(
                                          isCurrentMonthDay ? 0.8 : 0.3)
                                      : AppColors.textLight.withOpacity(
                                          isCurrentMonthDay ? 0.8 : 0.3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Goal Met', Colors.green, isDark),
              _buildLegendItem('> 50%', primaryColor, isDark),
              _buildLegendItem('< 50%', Colors.orange, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? AppColors.textDark.withOpacity(0.7)
                : AppColors.textLight.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}