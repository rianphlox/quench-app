import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import '../constants/app_constants.dart';

class WaveProgress extends StatefulWidget {
  final double percentage;
  final String themeColor;
  final double size;

  const WaveProgress({
    super.key,
    required this.percentage,
    required this.themeColor,
    this.size = 200.0,
  });

  @override
  State<WaveProgress> createState() => _WaveProgressState();
}

class _WaveProgressState extends State<WaveProgress>
    with TickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  double _currentPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveAnimationController.repeat();

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percentage,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimationController.forward();
    _currentPercentage = widget.percentage;
  }

  @override
  void didUpdateWidget(WaveProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _progressAnimation = Tween<double>(
        begin: _currentPercentage,
        end: widget.percentage,
      ).animate(CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ));
      _progressAnimationController.reset();
      _progressAnimationController.forward();
      _currentPercentage = widget.percentage;
    }
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  Color _getThemeColor() {
    final themeColorObj = themeColors.firstWhere(
      (color) => color.value == widget.themeColor,
      orElse: () => themeColors.first,
    );
    return themeColorObj.color;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = _getThemeColor();

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final clampedPercentage = _progressAnimation.value.clamp(0.0, 100.0);

        return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 3.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06b6d4).withOpacity(0.3), // Exact React cyan shadow
            blurRadius: 20.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Background
            Container(
              color: isDark
                ? AppColors.darkBackground.withOpacity(0.5)
                : Colors.white.withOpacity(0.8),
            ),
            // Wave animation
            if (clampedPercentage > 0)
              AnimatedBuilder(
                animation: _waveAnimationController,
                builder: (context, child) {
                  return Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: widget.size * (clampedPercentage / 100),
                    child: WaveWidget(
                  config: CustomConfig(
                    gradients: [
                      [
                        const Color(0xFF06b6d4).withOpacity(0.6), // Exact React cyan
                        const Color(0xFF06b6d4).withOpacity(0.8),
                      ],
                      [
                        const Color(0xFF0891b2).withOpacity(0.8), // Cyan-600 for depth
                        const Color(0xFF0891b2),
                      ],
                    ],
                    durations: [35000, 19440],
                    heightPercentages: [0.20, 0.25],
                    gradientBegin: Alignment.bottomLeft,
                    gradientEnd: Alignment.topRight,
                  ),
                      waveAmplitude: 10.0,
                      size: Size(widget.size, widget.size * (clampedPercentage / 100)),
                    ),
                  );
                },
              ),
            // Percentage text overlay
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${clampedPercentage.toInt()}%',
                    style: TextStyle(
                      fontSize: widget.size * 0.15,
                      fontWeight: FontWeight.bold,
                      color: clampedPercentage > 50
                        ? Colors.white
                        : (isDark ? AppColors.textDark : AppColors.textLight),
                      shadows: clampedPercentage > 50
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2.0,
                            ),
                          ]
                        : null,
                    ),
                  ),
                  if (clampedPercentage >= 100)
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Text(
                        'Goal Reached!',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
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