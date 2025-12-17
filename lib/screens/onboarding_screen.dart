import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _iconController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  final List<OnboardingStep> _steps = [
    const OnboardingStep(
      title: "Stay Hydrated",
      description: "Quench helps you stay hydrated with timely reminders to drink water.",
      icon: Icons.water_drop,
      iconColor: Color(0xFF06b6d4), // Cyan-500
      gradientColors: [
        Color(0xFFf0fdff), // Cyan-50
        Color(0xFFdbeafe), // Blue-50
      ],
      gradientColorsDark: [
        Color(0xFF164e63), // Cyan-900/20 equivalent
        Color(0xFF1e3a8a), // Blue-900/20 equivalent
      ],
    ),
    const OnboardingStep(
      title: "Word of Wisdom",
      description: "\"Water is important; if you would drink it regularly, you would hardly be sick\" — Rev. Dr Chris Oyakhilome",
      icon: Icons.favorite,
      iconColor: Color(0xFFf43f5e), // Rose-500
      gradientColors: [
        Color(0xFFfff1f2), // Rose-50
        Color(0xFFfdf2f8), // Pink-50
      ],
      gradientColorsDark: [
        Color(0xFF881337), // Rose-900/20 equivalent
        Color(0xFF831843), // Pink-900/20 equivalent
      ],
    ),
    const OnboardingStep(
      title: "Track Your Intake",
      description: "Log your daily water consumption easily and watch your hydration wave rise. View historical charts to track your habits.",
      icon: Icons.bar_chart,
      iconColor: Color(0xFF3b82f6), // Blue-500
      gradientColors: [
        Color(0xFFdbeafe), // Blue-50
        Color(0xFFe0e7ff), // Indigo-50
      ],
      gradientColorsDark: [
        Color(0xFF1e3a8a), // Blue-900/20 equivalent
        Color(0xFF312e81), // Indigo-900/20 equivalent
      ],
    ),
    const OnboardingStep(
      title: "Earn Rewards",
      description: "Build streaks, unlock achievements, and stay motivated on your journey to better health.",
      icon: Icons.emoji_events,
      iconColor: Color(0xFF8b5cf6), // Purple-500
      gradientColors: [
        Color(0xFFfaf5ff), // Purple-50
        Color(0xFFfdf4ff), // Fuchsia-50
      ],
      gradientColorsDark: [
        Color(0xFF581c87), // Purple-900/20 equivalent
        Color(0xFF701a75), // Fuchsia-900/20 equivalent
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _iconController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleNext() async {
    _scaleController.forward().then((_) => _scaleController.reverse());

    if (_currentStep < _steps.length - 1) {
      // Animate out current step
      await _slideController.reverse();
      await _iconController.reverse();

      setState(() {
        _currentStep++;
      });

      // Animate in new step
      await _iconController.forward();
      await _slideController.forward();
    } else {
      widget.onComplete();
    }
  }

  void _handleSkip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Skip Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF93c5fd) // Blue-300
                            : const Color(0xFF94a3b8), // Slate-400
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Main Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Icon Container
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _iconController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark ? step.gradientColorsDark : step.gradientColors,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: Icon(
                          step.icon,
                          size: 80,
                          color: step.iconColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Animated Title
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _slideController,
                          curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _slideController,
                        child: Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1e293b), // Slate-800
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Animated Description
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _slideController,
                          curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _slideController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            step.description,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: isDark
                                  ? const Color(0xFF93c5fd) // Blue-200
                                  : const Color(0xFF64748b), // Slate-500
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer Controls
              Column(
                children: [
                  // Pagination Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _currentStep ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentStep
                              ? (isDark ? Colors.white : const Color(0xFF1e293b)) // Slate-800
                              : (isDark
                                  ? const Color(0xFF1e3a8a) // Blue-900
                                  : const Color(0xFFe2e8f0)), // Slate-200
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Action Button
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 0.98).animate(
                      _scaleController,
                    ),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : const Color(0xFF0f172a), // Slate-900
                          foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == _steps.length - 1 ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentStep == _steps.length - 1
                                  ? Icons.arrow_forward
                                  : Icons.chevron_right,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final List<Color> gradientColorsDark;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.gradientColorsDark,
  });
}