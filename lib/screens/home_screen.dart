import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/app_provider.dart';
import '../widgets/wave_progress.dart';
import '../widgets/water_controls.dart';
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
        final primaryColor = const Color(0xFF06b6d4); // Always use cyan blue for aqua theme

        return Theme(
          data: Theme.of(context).copyWith(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            appBarTheme: AppBarTheme(
              backgroundColor: isDark
                  ? AppColors.primaryBlue.withAlpha((255 * 0.9).round())
                  : Colors.white.withAlpha((255 * 0.8).round()),
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
                          ? AppColors.primaryBlue.withAlpha((255 * 0.9).round())
                          : Colors.white.withAlpha((255 * 0.8).round()),
                      title: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: AppAssets.quenchLogo,
                            width: 32,
                            height: 32,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.water_drop,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 10,
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0f172a), // Slate-900
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
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
                                : (isDark ? AppColors.textDark.withAlpha((255 * 0.5).round()) : AppColors.textLight.withAlpha((255 * 0.5).round())),
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
                                                        .withAlpha((255 * 0.3).round())
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
                                                          .withAlpha((255 * 0.8).round())
                                                      : AppColors.textLight
                                                          .withAlpha((255 * 0.8).round()),
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
                                                  .withAlpha((255 * 0.5).round())
                                              : AppColors.textLight
                                                  .withAlpha((255 * 0.5).round()),
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
                // Goal Achievement Confetti (from top center)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: provider.goalConfettiController,
                    blastDirection: 1.57, // radians - 90 degrees (downward)
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    colors: const [
                      Color(0xFF06b6d4), // Primary cyan
                      Color(0xFF0891b2), // Cyan-600
                      Color(0xFF0e7490), // Cyan-700
                      Color(0xFF22d3ee), // Cyan-400
                      Color(0xFF67e8f9), // Cyan-300
                      Colors.white,
                    ],
                    createParticlePath: (size) {
                      final path = Path();
                      // Create water drop shaped particles
                      path.addOval(Rect.fromCircle(
                        center: Offset(size.width / 2, size.height / 2),
                        radius: 4,
                      ));
                      // Add some star shapes
                      if (size.width > 6) {
                        path.addPolygon([
                          Offset(size.width / 2, 0),
                          Offset(size.width * 0.6, size.height * 0.35),
                          Offset(size.width, size.height * 0.35),
                          Offset(size.width * 0.7, size.height * 0.6),
                          Offset(size.width * 0.8, size.height),
                          Offset(size.width / 2, size.height * 0.75),
                          Offset(size.width * 0.2, size.height),
                          Offset(size.width * 0.3, size.height * 0.6),
                          Offset(0, size.height * 0.35),
                          Offset(size.width * 0.4, size.height * 0.35),
                        ], true);
                      }
                      return path;
                    },
                    emissionFrequency: 0.02,
                    numberOfParticles: 80,
                    maxBlastForce: 35,
                    minBlastForce: 15,
                    gravity: 0.08,
                  ),
                ),
                // Badge Achievement Confetti (from sides)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConfettiWidget(
                    confettiController: provider.badgeConfettiController,
                    blastDirection: 0, // radians - rightward
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.02,
                    colors: const [
                      Color(0xFFffd700), // Gold
                      Colors.orange,
                      Colors.amber,
                      Colors.yellow,
                      Color(0xFFfbbf24), // Amber-400
                      Color(0xFFf59e0b), // Amber-500
                    ],
                    createParticlePath: (size) {
                      final path = Path();
                      // Create trophy/badge shaped particles
                      path.addRRect(RRect.fromRectAndRadius(
                        Rect.fromLTWH(0, 0, size.width, size.height),
                        Radius.circular(size.width * 0.3),
                      ));
                      // Add diamond shape
                      if (size.width > 4) {
                        path.addPolygon([
                          Offset(size.width / 2, 0),
                          Offset(size.width, size.height / 2),
                          Offset(size.width / 2, size.height),
                          Offset(0, size.height / 2),
                        ], true);
                      }
                      return path;
                    },
                    emissionFrequency: 0.01,
                    numberOfParticles: 60,
                    maxBlastForce: 30,
                    minBlastForce: 12,
                    gravity: 0.06,
                  ),
                ),
                // Badge Achievement Confetti (from right side)
                Align(
                  alignment: Alignment.centerRight,
                  child: ConfettiWidget(
                    confettiController: provider.badgeConfettiController,
                    blastDirection: 3.14, // radians - leftward
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.02,
                    colors: const [
                      Color(0xFFffd700), // Gold
                      Colors.orange,
                      Colors.amber,
                      Colors.yellow,
                      Color(0xFFfbbf24), // Amber-400
                      Color(0xFFf59e0b), // Amber-500
                    ],
                    createParticlePath: (size) {
                      final path = Path();
                      // Create trophy/badge shaped particles
                      path.addRRect(RRect.fromRectAndRadius(
                        Rect.fromLTWH(0, 0, size.width, size.height),
                        Radius.circular(size.width * 0.3),
                      ));
                      return path;
                    },
                    emissionFrequency: 0.01,
                    numberOfParticles: 60,
                    maxBlastForce: 30,
                    minBlastForce: 12,
                    gravity: 0.06,
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