import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _isVisible = true;
  late AnimationController _logoController;
  late AnimationController _quoteController;
  late AnimationController _dotsController;
  late AnimationController _fadeController;

  late Animation<double> _logoAnimation;
  late Animation<Offset> _quoteSlideAnimation;
  late Animation<double> _quoteOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation - zoom in effect
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Quote animation - slide up and fade in
    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Loading dots animation
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Final fade out animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Setup animations
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _quoteSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeOutCubic,
    ));

    _quoteOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation immediately
    _logoController.forward();

    // Start dots animation
    _dotsController.repeat();

    // Start quote animation after 500ms delay
    await Future.delayed(const Duration(milliseconds: 500));
    _quoteController.forward();

    // Show splash for 3.5 seconds total, then fade out
    await Future.delayed(const Duration(milliseconds: 3000));
    setState(() {
      _isVisible = false;
    });

    // Start fade out animation
    _fadeController.forward();

    // Give time for the fade-out transition before finishing
    await Future.delayed(const Duration(milliseconds: 700));
    widget.onFinish();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _quoteController.dispose();
    _dotsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildLoadingDot(int index, int delay) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        final animationValue = (_dotsController.value * 3 - (delay / 150)).clamp(0.0, 1.0);
        final bounceValue = (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, -8 * bounceValue),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientCyan, // #06b6d4
                AppColors.gradientBlue, // #3b82f6
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Logo Section - takes flex-1 space
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container with glassmorphism effect
                        ScaleTransition(
                          scale: _logoAnimation,
                          child: FadeTransition(
                            opacity: _logoAnimation,
                            child: Transform.rotate(
                              angle: 0.05, // 3 degrees rotation
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 32,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Center(
                                    child: CachedNetworkImage(
                                      imageUrl: AppAssets.quenchLogo,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Container(
                                        width: 96,
                                        height: 96,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.water_drop,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 96,
                                        height: 96,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.water_drop,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // App name
                        ScaleTransition(
                          scale: _logoAnimation,
                          child: FadeTransition(
                            opacity: _logoAnimation,
                            child: const Text(
                              'Quench',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        ScaleTransition(
                          scale: _logoAnimation,
                          child: FadeTransition(
                            opacity: _logoAnimation,
                            child: const Text(
                              'SMART HYDRATION COMPANION',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFa5f3fc), // cyan-200
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quote Section
                  SlideTransition(
                    position: _quoteSlideAnimation,
                    child: FadeTransition(
                      opacity: _quoteOpacityAnimation,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 384),
                        child: Column(
                          children: [
                            // Quote text with quotation marks
                            Stack(
                              children: [
                                // Opening quote
                                const Positioned(
                                  top: -16,
                                  left: -8,
                                  child: Text(
                                    '"',
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: Colors.white30,
                                      height: 0.5,
                                    ),
                                  ),
                                ),
                                // Main quote
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Water is important; if you would drink it regularly, you would hardly be sick',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(alpha: 0.95),
                                      height: 1.4,
                                      fontStyle: FontStyle.italic,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // Closing quote
                                const Positioned(
                                  bottom: -24,
                                  right: -8,
                                  child: Text(
                                    '"',
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: Colors.white30,
                                      height: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Author
                            const Text(
                              '- REV. DR CHRIS OYAKHILOME',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFa5f3fc), // cyan-200
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading Dots
                  Opacity(
                    opacity: 0.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLoadingDot(0, 0),
                        const SizedBox(width: 8),
                        _buildLoadingDot(1, 150),
                        const SizedBox(width: 8),
                        _buildLoadingDot(2, 300),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}