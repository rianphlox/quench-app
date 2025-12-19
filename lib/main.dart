import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/app_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.init();

  // Initialize notification service (non-blocking)
  try {
    await NotificationService.initialize();
    debugPrint('✅ Notifications initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Notifications not available: $e');
    // App continues without notifications
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const QuenchApp());
}

class QuenchApp extends StatelessWidget {
  const QuenchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final isDark = provider.settings.darkMode;
          final primaryColor = themeColors.firstWhere(
            (color) => color.value == provider.settings.themeColor,
            orElse: () => themeColors.first,
          ).color;

          return AnimatedBuilder(
            animation: provider,
            builder: (context, child) {
              return MaterialApp(
                title: 'Quench - Hydration Tracker',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: _createMaterialColor(primaryColor),
              primaryColor: primaryColor,
              scaffoldBackgroundColor: AppColors.lightBackground,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.white.withAlpha((255 * 0.8).round()),
                foregroundColor: AppColors.lightPrimaryText,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
              cardTheme: const CardThemeData(
                color: AppColors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: AppColors.textLight),
                bodyMedium: TextStyle(color: AppColors.textLight),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: _createMaterialColor(primaryColor),
              primaryColor: primaryColor,
              scaffoldBackgroundColor: AppColors.darkBackground,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.darkBackground.withAlpha((255 * 0.9).round()),
                foregroundColor: AppColors.textDark,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              cardTheme: CardThemeData(
                color: AppColors.darkCard,
                elevation: 2,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: AppColors.textDark),
                bodyMedium: TextStyle(color: AppColors.textDark),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                themeAnimationDuration: const Duration(milliseconds: 400),
                themeAnimationCurve: Curves.easeInOut,
                home: const AppStateManager(),
              );
            },
          );
        },
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = (color.value >> 16) & 0xFF;
    final int g = (color.value >> 8) & 0xFF;
    final int b = color.value & 0xFF;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

enum AppState { splash, onboarding, main }

class AppStateManager extends StatefulWidget {
  const AppStateManager({super.key});

  @override
  State<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends State<AppStateManager> {
  AppState _currentState = AppState.splash;

  @override
  void initState() {
    super.initState();
    // Start in splash state by default
  }

  void _handleSplashFinish() async {
    // Check if user has completed onboarding
    final hasCompletedOnboarding = StorageService.getBool('onboarding_completed') ?? false;

    setState(() {
      if (hasCompletedOnboarding) {
        _currentState = AppState.main;
      } else {
        _currentState = AppState.onboarding;
      }
    });
  }

  void _handleOnboardingComplete() async {
    // Save that onboarding is completed
    await StorageService.setBool('onboarding_completed', true);

    setState(() {
      _currentState = AppState.main;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case AppState.splash:
        return SplashScreen(onFinish: _handleSplashFinish);
      case AppState.onboarding:
        return OnboardingScreen(onComplete: _handleOnboardingComplete);
      case AppState.main:
        return const HomeScreen();
    }
  }
}
