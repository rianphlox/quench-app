import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../constants/app_constants.dart';

class WaterControls extends StatefulWidget {
  final Function(double) onAddWater;
  final String themeColor;

  const WaterControls({
    super.key,
    required this.onAddWater,
    required this.themeColor,
  });

  @override
  State<WaterControls> createState() => _WaterControlsState();
}

class _WaterControlsState extends State<WaterControls>
    with TickerProviderStateMixin {
  late AnimationController _staggerAnimationController;
  final List<AnimationController> _buttonAnimationControllers = [];
  bool _isCustomOpen = false;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _staggerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create animation controllers for each button (5 presets + 1 custom)
    for (int i = 0; i < 6; i++) {
      _buttonAnimationControllers.add(
        AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        ),
      );
    }

    _staggerAnimationController.forward();
  }

  @override
  void dispose() {
    _staggerAnimationController.dispose();
    for (final controller in _buttonAnimationControllers) {
      controller.dispose();
    }
    _customController.dispose();
    super.dispose();
  }

  void _onButtonTap(int index, double amount) {
    // Animate button press
    _buttonAnimationControllers[index].forward().then((_) {
      _buttonAnimationControllers[index].reverse();
    });

    widget.onAddWater(amount);
  }

  void _onCustomTap() {
    setState(() {
      _isCustomOpen = !_isCustomOpen;
    });
  }

  void _handleCustomSubmit() {
    final amount = double.tryParse(_customController.text);
    if (amount != null && amount > 0) {
      widget.onAddWater(amount);
      _customController.clear();
      setState(() {
        _isCustomOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 384), // max-w-md
      child: Column(
        children: [
          // 3x2 Grid with presets + custom button
          AnimationLimiter(
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              childAspectRatio: 1.0,
              children: [
                // First 5 preset buttons
                ...presetVolumes.take(5).map((preset) {
                  final index = presetVolumes.indexOf(preset);
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    columnCount: 3,
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: AnimatedBuilder(
                          animation: _buttonAnimationControllers[index],
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 - (_buttonAnimationControllers[index].value * 0.05),
                              child: _WaterControlButton(
                                label: preset.label,
                                amount: preset.amount,
                                icon: preset.icon,
                                isDark: isDark,
                                onTap: () => _onButtonTap(index, preset.amount),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
                // Custom button as 6th item
                AnimationConfiguration.staggeredGrid(
                  position: 5,
                  duration: const Duration(milliseconds: 500),
                  columnCount: 3,
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: _CustomButton(
                        isActive: _isCustomOpen,
                        isDark: isDark,
                        onTap: _onCustomTap,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Custom amount input (appears when custom button is pressed)
          if (_isCustomOpen) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFdbeafe) : const Color(0xFF334155), // blue-50 : slate-700
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter amount in ml',
                        hintStyle: TextStyle(
                          color: isDark ? const Color(0xFF93c5fd) : const Color(0xFF94a3b8), // blue-300 : slate-400
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : Colors.white, // #152370 : white
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkBorder : const Color(0xFFe2e8f0), // #1d2a75 : slate-200
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkBorder : const Color(0xFFe2e8f0), // #1d2a75 : slate-200
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF06b6d4), // cyan-500
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _customController.text.isNotEmpty ? _handleCustomSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06b6d4), // cyan-500
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF06b6d4).withAlpha((255 * 0.5).round()),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF06b6d4).withAlpha((255 * 0.2).round()),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WaterControlButton extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _WaterControlButton({
    required this.label,
    required this.amount,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white, // #152370 : white
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFe2e8f0), // #1d2a75 : slate-200
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * (isDark ? 0.1 : 0.04)).round()),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? const Color(0xFF93c5fd) : const Color(0xFF06b6d4), // blue-300 : cyan-500
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFdbeafe) : const Color(0xFF475569), // blue-50 : slate-600
                ),
              ),
              Text(
                '${amount.toInt()}ml',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF93c5fd) : const Color(0xFF94a3b8), // blue-300 : slate-400
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _CustomButton({
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF0f172a) : const Color(0xFF0f172a)) // slate-800
                : (isDark ? AppColors.darkCard : Colors.white), // #152370 : white
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF0f172a) // slate-800
                  : (isDark ? AppColors.darkBorder : const Color(0xFFe2e8f0)), // #1d2a75 : slate-200
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * (isDark ? 0.1 : 0.04)).round()),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 20,
                color: isActive
                    ? Colors.white
                    : (isDark ? const Color(0xFFdbeafe) : const Color(0xFF475569)), // white : blue-50 : slate-600
              ),
              const SizedBox(height: 4),
              Text(
                'Custom',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : (isDark ? const Color(0xFFdbeafe) : const Color(0xFF475569)), // white : blue-50 : slate-600
                ),
              ),
              Text(
                '...ml',
                style: TextStyle(
                  fontSize: 10,
                  color: isActive
                      ? Colors.white60
                      : (isDark ? const Color(0xFF93c5fd) : const Color(0xFF94a3b8)), // white60 : blue-300 : slate-400
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}