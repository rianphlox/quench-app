import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class TooltipWidget extends StatefulWidget {
  final String content;
  final Widget child;
  final TooltipPosition position;

  const TooltipWidget({
    super.key,
    required this.content,
    required this.child,
    this.position = TooltipPosition.top,
  });

  @override
  State<TooltipWidget> createState() => _TooltipWidgetState();
}

enum TooltipPosition { top, bottom, left, right }

class _TooltipWidgetState extends State<TooltipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    setState(() {
      _isVisible = true;
    });
    _animationController.forward();
  }

  void _hideTooltip() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _isVisible ? _hideTooltip : _showTooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_isVisible)
            _buildPositionedTooltip(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: Opacity(
                      opacity: _animation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.lightBlue : Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Text(
                          widget.content,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPositionedTooltip({required Widget child}) {
    switch (widget.position) {
      case TooltipPosition.top:
        return Positioned(
          bottom: 40,
          left: -50,
          child: child,
        );
      case TooltipPosition.bottom:
        return Positioned(
          top: 40,
          left: -50,
          child: child,
        );
      case TooltipPosition.left:
        return Positioned(
          right: 40,
          top: -20,
          child: child,
        );
      case TooltipPosition.right:
        return Positioned(
          left: 40,
          top: -20,
          child: child,
        );
    }
  }
}