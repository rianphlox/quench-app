import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../constants/app_constants.dart';
import '../models/user_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _dailyGoalController;

  @override
  void initState() {
    super.initState();
    _dailyGoalController = TextEditingController();
  }

  @override
  void dispose() {
    _dailyGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isDark = provider.settings.darkMode;
        final primaryColor = themeColors.firstWhere(
          (color) => color.value == provider.settings.themeColor,
          orElse: () => themeColors.first,
        ).color;

        _dailyGoalController.text = provider.settings.dailyGoal.toInt().toString();

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
                'Preferences',
                style: TextStyle(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: _buildPreferencesContent(context, provider, isDark, primaryColor),
          ),
        );
      },
    );
  }

  Widget _buildPreferencesContent(BuildContext context, AppProvider provider, bool isDark, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Goal Section
          _buildSection(
            'Daily Goal',
            Icons.track_changes,
            isDark,
            primaryColor,
            [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dailyGoalController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Target Intake (ml)',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textDark.withOpacity(0.7)
                              : AppColors.textLight.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.lightBlue.withOpacity(0.1)
                            : Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onSubmitted: (value) => _updateDailyGoal(provider, value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Recommended: 2500ml for adults',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.6)
                      : AppColors.textLight.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Reminders Section
          _buildSection(
            'Reminders',
            Icons.notifications,
            isDark,
            primaryColor,
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enable Reminders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  Switch(
                    value: provider.settings.reminderEnabled,
                    onChanged: (value) {
                      final newSettings = provider.settings.copyWith(reminderEnabled: value);
                      provider.updateSettings(newSettings);
                    },
                    activeColor: primaryColor,
                  ),
                ],
              ),
              if (provider.settings.reminderEnabled) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.lightBlue.withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeField(
                              'Start Time',
                              provider.settings.reminderStartTime,
                              isDark,
                              primaryColor,
                              () => _selectTime(context, provider, true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeField(
                              'End Time',
                              provider.settings.reminderEndTime,
                              isDark,
                              primaryColor,
                              () => _selectTime(context, provider, false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Frequency',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textDark.withOpacity(0.7)
                                      : AppColors.textLight.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: isDark
                                    ? AppColors.textDark.withOpacity(0.5)
                                    : AppColors.textLight.withOpacity(0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: provider.settings.reminderInterval,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                              filled: true,
                              fillColor: isDark ? AppColors.lightBlue.withOpacity(0.1) : Colors.white,
                            ),
                            dropdownColor: isDark ? AppColors.primaryBlue : Colors.white,
                            style: TextStyle(
                              color: isDark ? AppColors.textDark : AppColors.textLight,
                            ),
                            items: [30, 45, 60, 90, 120, 180].map((minutes) {
                              String label;
                              if (minutes < 60) {
                                label = 'Every $minutes minutes';
                              } else if (minutes == 60) {
                                label = 'Every 1 hour';
                              } else {
                                double hours = minutes / 60;
                                if (hours == hours.toInt()) {
                                  label = 'Every ${hours.toInt()} hours';
                                } else {
                                  label = 'Every ${hours.toStringAsFixed(1)} hours';
                                }
                              }

                              return DropdownMenuItem(
                                value: minutes,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                final newSettings = provider.settings.copyWith(reminderInterval: value);
                                provider.updateSettings(newSettings);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, bool isDark, Color primaryColor, List<Widget> children) {
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
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTimeField(String label, String value, bool isDark, Color primaryColor, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textDark.withOpacity(0.7)
                : AppColors.textLight.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? AppColors.lightBlue.withOpacity(0.1) : Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.5)
                      : AppColors.textLight.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _updateDailyGoal(AppProvider provider, String value) {
    final goal = double.tryParse(value);
    if (goal != null && goal > 0) {
      final newSettings = provider.settings.copyWith(dailyGoal: goal);
      provider.updateSettings(newSettings);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily goal updated to ${goal.toInt()}ml')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, AppProvider provider, bool isStartTime) async {
    final currentTime = isStartTime
        ? _parseTime(provider.settings.reminderStartTime)
        : _parseTime(provider.settings.reminderEndTime);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final newSettings = isStartTime
          ? provider.settings.copyWith(reminderStartTime: timeString)
          : provider.settings.copyWith(reminderEndTime: timeString);
      provider.updateSettings(newSettings);
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  void _showClearDataDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to clear all data? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.clearAllData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}