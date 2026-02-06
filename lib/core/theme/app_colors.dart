import 'package:flutter/material.dart';

class AppColors {
  // Primary colors (Blue theme)
  static const primaryBlue = Color(0xFF2196F3);
  static const secondaryBlue = Color(0xFF64B5F6);
  static const accentBlue = Color(0xFF1976D2);

  // Mood gradient colors
  static const moodRed = Color(0xFFD32F2F);
  static const moodYellow = Color(0xFFFFD600);
  static const moodGreen = Color(0xFF43A047);

  // Sleep quality colors
  static const sleepOptimal = Colors.green;
  static const sleepModerate = Colors.yellow;
  static const sleepPoor = Colors.red;

  // Light theme colors
  static const lightBackground = Color(0xFFf5f5f5);
  static const lightSurface = Color(0xFFffffff);
  static const lightText = Color(0xFF333333);

  // Dark theme colors
  static const darkBackground = Color(0xFF1a1a1a);
  static const darkSurface = Color(0xFF2a2a2a);
  static const darkText = Color(0xFFe0e0e0);

  // Button gradients (Blue theme)
  static const gradient1 = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradient2 = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Mood gradient calculator
  static Color forMoodValue(int mood) {
    if (mood <= 5) {
      // Interpolate between red (mood 1) and yellow (mood 5)
      final progress = (mood - 1) / (5 - 1);
      return Color.lerp(moodRed, moodYellow, progress)!;
    } else {
      // Interpolate between yellow (mood 5) and green (mood 10)
      final progress = (mood - 5) / (10 - 5);
      return Color.lerp(moodYellow, moodGreen, progress)!;
    }
  }

  static String emojiForMood(int mood) {
    if (mood <= 3) return '😞';
    if (mood <= 7) return '😐';
    return '😊';
  }
}
