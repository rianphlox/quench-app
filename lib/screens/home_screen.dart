import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/app_provider.dart';
import '../widgets/wave_progress.dart';
import '../widgets/water_controls.dart';
import '../widgets/streak_counter.dart';
import '../constants/app_constants.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'settings_screen.dart';
import 'insights_main_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _handleNotificationToggle(BuildContext context, AppProvider provider) async {
    final wasEnabled = provider.settings.reminderEnabled;
    final newSettings = provider.settings.copyWith(
      reminderEnabled: !provider.settings.reminderEnabled,
    );
    await provider.updateSettings(newSettings);

    // Show test notification only when enabling for the first time
    if (newSettings.reminderEnabled && !wasEnabled) {
      // Check if this is the first time enabling notifications
      final hasSeenTestNotification = StorageService.getBool('has_seen_test_notification') ?? false;

      if (!hasSeenTestNotification) {
        try {
          await NotificationService.showInstantNotification(
            title: "💧 Quench Reminders Enabled!",
            body: "You'll receive regular reminders to stay hydrated",
          );
          await StorageService.setBool('has_seen_test_notification', true);
        } catch (e) {
          debugPrint('Error showing test notification: $e');
        }
      }
    }

    // Check if context is still mounted before using it
    if (!context.mounted) return;

    // Show feedback snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newSettings.reminderEnabled
              ? 'Water reminders enabled! 💧'
              : 'Water reminders disabled'
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: newSettings.reminderEnabled
            ? const Color(0xFF06b6d4)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isDark = provider.settings.darkMode;
        final themeColor = provider.settings.themeColor;
        final primaryColor = const Color(0xFF06b6d4); // Always use cyan blue for aqua theme

        return Theme(
          data: Theme.of(context).copyWith(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            appBarTheme: AppBarTheme(
              backgroundColor: isDark
                  ? AppColors.primaryBlue.withOpacity(0.9)
                  : Colors.white.withOpacity(0.8),
              foregroundColor:
                  isDark ? AppColors.textDark : AppColors.textLight,
              elevation: 0,
            ),
          ),
          child: Scaffold(
            body: Stack(
              children: [
                // Main content
                CustomScrollView(
                  slivers: [
                    // App bar
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      backgroundColor: isDark
                          ? AppColors.primaryBlue.withOpacity(0.9)
                          : Colors.white.withOpacity(0.8),
                      title: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: AppAssets.quenchLogo,
                            width: 40,
                            height: 40,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.water_drop,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFF93c5fd) // Blue-300
                                      : const Color(0xFF64748b), // Slate-500
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'Esteemed',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0f172a), // Slate-900
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        StreakCounter(streak: provider.currentStreak),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _handleNotificationToggle(context, provider);
                          },
                          icon: Icon(
                            provider.settings.reminderEnabled
                                ? Icons.notifications
                                : Icons.notifications_off,
                            color: provider.settings.reminderEnabled
                                ? primaryColor
                                : (isDark ? AppColors.textDark.withOpacity(0.5) : AppColors.textLight.withOpacity(0.5)),
                          ),
                          tooltip: provider.settings.reminderEnabled
                              ? 'Reminders On'
                              : 'Reminders Off',
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const InsightsMainScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.insights),
                          tooltip: 'Insights',
                        ),
                        IconButton(
                          onPressed: () {
                            final newSettings = provider.settings.copyWith(
                              darkMode: !provider.settings.darkMode,
                            );
                            provider.updateSettings(newSettings);
                          },
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                          ),
                          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings),
                          tooltip: 'Settings',
                        ),
                      ],
                    ),
                    // Main content
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 20),
                          // Wave progress section
                          AnimationLimiter(
                            child: Column(
                              children: AnimationConfiguration.toStaggeredList(
                                duration: const Duration(milliseconds: 600),
                                childAnimationBuilder: (widget) =>
                                    SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(child: widget),
                                ),
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        // Animated Hero Wave Progress
                                        Hero(
                                          tag: 'wave_progress',
                                          child: WaveProgress(
                                            percentage:
                                                provider.progressPercentage,
                                            themeColor: 'cyan',
                                            size: 200.0,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        // Stats
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  provider.todayTotal
                                                      .toInt()
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 56,
                                                    fontWeight: FontWeight.w800,
                                                    color: isDark
                                                        ? AppColors.textDark
                                                        : AppColors.textLight,
                                                    height: 1.0,
                                                  ),
                                                ),
                                                Text(
                                                  'ml',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w600,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? AppColors.lightBlue
                                                        .withOpacity(0.3)
                                                    : AppColors.borderLight,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Goal: ${provider.settings.dailyGoal.toInt()}ml',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? AppColors.textDark
                                                          .withOpacity(0.8)
                                                      : AppColors.textLight
                                                          .withOpacity(0.8),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            if (provider.remainingToday > 0)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    '💧 ',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  Text(
                                                    '${provider.remainingToday.toInt()}ml to reach daily goal',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Text(
                                                    '✨ ',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  Text(
                                                    'Daily goal completed!',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // Animated Water controls
                                  WaterControls(
                                    onAddWater: provider.addWater,
                                    themeColor: 'cyan',
                                  ),
                                  const SizedBox(height: 40),
                                  // Footer
                                  Column(
                                    children: [
                                      SvgPicture.network(
                                        AppAssets.qubatorsLogo,
                                        height: 32,
                                        colorFilter: ColorFilter.mode(
                                          isDark ? Colors.white : Colors.black,
                                          BlendMode.srcIn,
                                        ),
                                        placeholderBuilder: (context) =>
                                            const SizedBox.shrink(),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Thank you for using our app. Kindly reach out to us on KingsChat @qubatorsnet or via email dev@qubators.org for your suggestions or feedback.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? AppColors.textDark
                                                  .withOpacity(0.5)
                                              : AppColors.textLight
                                                  .withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                // Confetti overlay
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: provider.confettiController,
                    blastDirection: 1.57, // radians - 90 degrees
                    createParticlePath: (size) {
                      return Path()
                        ..addOval(Rect.fromCircle(
                            center: Offset(size.width / 2, size.height / 2),
                            radius: 3));
                    },
                    emissionFrequency: 0.05,
                    numberOfParticles: 50,
                    maxBlastForce: 20,
                    minBlastForce: 10,
                    gravity: 0.1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}