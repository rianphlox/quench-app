import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../models/badge.dart' as app_badge;

const UserSettings defaultSettings = UserSettings(
  dailyGoal: 2500,
  darkMode: false,
  themeColor: 'cyan',
  reminderEnabled: false,
  reminderInterval: 60,
  reminderStartTime: "09:00",
  reminderEndTime: "22:00",
);

class ThemeColor {
  final String label;
  final String value;
  final Color color;
  final String hueRotate;

  const ThemeColor({
    required this.label,
    required this.value,
    required this.color,
    required this.hueRotate,
  });
}

const List<ThemeColor> themeColors = [
  ThemeColor(
    label: 'Cyan',
    value: 'cyan',
    color: Color(0xFF06b6d4), // Exact match: #06b6d4
    hueRotate: '0deg',
  ),
  ThemeColor(
    label: 'Blue',
    value: 'blue',
    color: Color(0xFF3b82f6), // Exact match: #3b82f6
    hueRotate: '60deg',
  ),
  ThemeColor(
    label: 'Violet',
    value: 'violet',
    color: Color(0xFF8b5cf6), // Exact match: #8b5cf6
    hueRotate: '90deg',
  ),
  ThemeColor(
    label: 'Fuchsia',
    value: 'fuchsia',
    color: Color(0xFFd946ef), // Exact match: #d946ef
    hueRotate: '120deg',
  ),
  ThemeColor(
    label: 'Rose',
    value: 'rose',
    color: Color(0xFFf43f5e), // Exact match: #f43f5e
    hueRotate: '160deg',
  ),
  ThemeColor(
    label: 'Orange',
    value: 'orange',
    color: Color(0xFFf97316), // Exact match: #f97316
    hueRotate: '200deg',
  ),
  ThemeColor(
    label: 'Emerald',
    value: 'emerald',
    color: Color(0xFF10b981), // Exact match: #10b981
    hueRotate: '-20deg',
  ),
];

class PresetVolume {
  final String label;
  final double amount;
  final IconData icon;

  const PresetVolume({
    required this.label,
    required this.amount,
    required this.icon,
  });
}

const List<PresetVolume> presetVolumes = [
  PresetVolume(label: 'Sip', amount: 50, icon: Icons.water_drop),
  PresetVolume(label: 'Glass', amount: 250, icon: Icons.local_bar),
  PresetVolume(label: 'Mug', amount: 350, icon: Icons.coffee),
  PresetVolume(label: 'Bottle', amount: 500, icon: Icons.sports_bar),
  PresetVolume(label: 'Large', amount: 750, icon: Icons.local_drink),
];

const List<app_badge.Badge> availableBadges = [
  app_badge.Badge(
    id: 'streak_3',
    label: 'Good Start',
    description: 'Reach a 3-day streak',
    icon: '🔥',
  ),
  app_badge.Badge(
    id: 'streak_7',
    label: 'Week Warrior',
    description: 'Reach a 7-day streak',
    icon: '⚡',
  ),
  app_badge.Badge(
    id: 'streak_30',
    label: 'Monthly Master',
    description: 'Reach a 30-day streak',
    icon: '👑',
  ),
  app_badge.Badge(
    id: 'volume_100l',
    label: '100L Club',
    description: 'Log 100 Liters total all-time',
    icon: '💧',
  ),
  app_badge.Badge(
    id: 'perfect_week',
    label: 'Perfect Week',
    description: 'Meet daily goal for 7 days in a row',
    icon: '⭐',
  ),
  app_badge.Badge(
    id: 'early_bird',
    label: 'Sunrise Starter',
    description: 'Log water before 7:00 AM',
    icon: '🌅',
  ),
  app_badge.Badge(
    id: 'night_owl',
    label: 'Moonlight Sipper',
    description: 'Log water after 10:00 PM',
    icon: '🌙',
  ),
];

// App colors - Exact match to React app
class AppColors {
  // Dark Mode - "Midnight" theme
  static const Color darkBackground = Color(0xFF0a1250);      // Main Background
  static const Color darkCard = Color(0xFF152370);            // Card/Container Background
  static const Color darkModal = Color(0xFF0f1a5c);           // Modal Background
  static const Color darkBorder = Color(0xFF1d2a75);          // Borders & Dividers
  static const Color darkHover = Color(0xFF1f2d7a);           // Input Fields / Hover States

  // Light Mode - Standard Tailwind colors
  static const Color lightBackground = Color(0xFFf8fafc);     // bg-slate-50
  static const Color lightPrimaryText = Color(0xFF0f172a);    // text-slate-900
  static const Color lightSecondaryText = Color(0xFF64748b);  // text-slate-500
  static const Color white = Color(0xFFffffff);               // #ffffff

  // Legacy aliases for backward compatibility
  static const Color primaryBlue = Color(0xFF0a1250);         // Same as darkBackground
  static const Color lightBlue = Color(0xFF1d2a75);           // Same as darkBorder
  static const Color textLight = Color(0xFF334155);           // Slightly darker than secondary
  static const Color textDark = Color(0xFFf1f5f9);            // Light text for dark mode
  static const Color borderLight = Color(0xFFe2e8f0);         // Light border
  static const Color borderDark = Color(0xFF1d2a75);          // Same as darkBorder

  // Gradient colors for Splash & Onboarding
  static const Color gradientCyan = Color(0xFF06b6d4);        // Cyan-500
  static const Color gradientBlue = Color(0xFF3b82f6);        // Blue-500
}

// App Assets
class AppAssets {
  static const String quenchLogo = 'https://d1ent1.loveworldcloud.com/~rorm/1/8/Loveworld%20Karaoke/Images/Quench%20app%20logo.png';
  static const String qubatorsLogo = 'https://d1ent1.loveworldcloud.com/~rorm/1/8/Loveworld%20Karaoke/Images/Made%20by%20Qubators%20White.svg';
}