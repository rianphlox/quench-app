import 'package:flutter/material.dart';
import '../models/water_log.dart';

class HydrationCoach extends StatefulWidget {
  final double currentVolume;
  final double goal;
  final List<WaterLog> logs;

  const HydrationCoach({
    super.key,
    required this.currentVolume,
    required this.goal,
    required this.logs,
  });

  @override
  State<HydrationCoach> createState() => _HydrationCoachState();
}

class _HydrationCoachState extends State<HydrationCoach> {
  String _currentMessage = "Ready to hydrate? Let's go! 💧";
  int _messageIndex = 0;

  final List<String> _motivationalMessages = [
    "You're doing great! Keep up the hydration! 💧",
    "Water is life - and you're living it right! ✨",
    "Your body loves you for staying hydrated! 💙",
    "Small sips, big impact. Keep going! 🌊",
    "Hydration hero in the making! 🦸‍♀️",
    "Every drop counts towards your health! 💎",
    "You're glowing from the inside out! ✨",
    "H2O = Happy, Healthy Outcomes! 🎯",
    "Your cells are dancing with joy! 💃",
    "Flowing towards your best self! 🌟",
  ];

  final List<String> _goalReachedMessages = [
    "🎉 Goal smashed! You're a hydration champion!",
    "🏆 Daily goal complete! Your body thanks you!",
    "⭐ Amazing! You've mastered hydration today!",
    "🌟 Goal achieved! You're unstoppable!",
    "🎊 Fantastic! You're a water warrior!",
  ];

  final List<String> _encouragementMessages = [
    "You've got this! Just a little more to go! 💪",
    "Almost there! Your goal is within reach! 🎯",
    "Keep pushing! Great things are coming! 🚀",
    "You're so close! Don't give up now! 🌈",
    "Final stretch! You can do this! ⭐",
  ];

  @override
  void initState() {
    super.initState();
    _updateMessage();
  }

  @override
  void didUpdateWidget(HydrationCoach oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentVolume != widget.currentVolume) {
      _updateMessage();
    }
  }

  void _updateMessage() {
    setState(() {
      if (widget.currentVolume >= widget.goal) {
        _currentMessage = _goalReachedMessages[
            DateTime.now().millisecondsSinceEpoch % _goalReachedMessages.length];
      } else if (widget.currentVolume > widget.goal * 0.7) {
        _currentMessage = _encouragementMessages[
            DateTime.now().millisecondsSinceEpoch % _encouragementMessages.length];
      } else {
        _currentMessage = _motivationalMessages[
            DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length];
      }
    });
  }

  void _refreshMessage() {
    setState(() {
      _messageIndex = (_messageIndex + 1) % _motivationalMessages.length;
      if (widget.currentVolume >= widget.goal) {
        _currentMessage = _goalReachedMessages[_messageIndex % _goalReachedMessages.length];
      } else if (widget.currentVolume > widget.goal * 0.7) {
        _currentMessage = _encouragementMessages[_messageIndex % _encouragementMessages.length];
      } else {
        _currentMessage = _motivationalMessages[_messageIndex % _motivationalMessages.length];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.indigo.shade800, Colors.purple.shade800]
              : [Colors.indigo.shade500, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).round()),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((255 * 0.2).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.yellow,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HydroCoach AI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade100,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _refreshMessage,
              icon: const Icon(
                Icons.refresh,
                color: Colors.white70,
                size: 20,
              ),
              tooltip: 'Get new motivation',
            ),
          ],
        ),
      ),
    );
  }
}