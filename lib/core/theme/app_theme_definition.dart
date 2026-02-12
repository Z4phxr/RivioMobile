import 'package:flutter/material.dart';

/// Theme definition model based on backend reference (backedncolorsfor.py)
class AppThemeDefinition {
  final String key;
  final String displayName;
  final String backgroundImage;
  final Color gradientStart;
  final Color gradientEnd;
  final Color primaryColor;
  final Color accentColor;

  const AppThemeDefinition({
    required this.key,
    required this.displayName,
    required this.backgroundImage,
    required this.gradientStart,
    required this.gradientEnd,
    required this.primaryColor,
    required this.accentColor,
  });

  /// Create linear gradient from theme colors
  LinearGradient get gradient => LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Get background image path
  String get backgroundImagePath => 'assets/backgrounds/$backgroundImage';
}

/// Registry of all available themes based on backend THEME_CONFIG
class AppThemeRegistry {
  static const String defaultThemeKey = 'slate';

  /// All available themes (from backedncolorsfor.py THEME_CONFIG)
  static const List<AppThemeDefinition> themes = [
    AppThemeDefinition(
      key: 'purple',
      displayName: 'Purple',
      backgroundImage: 'bg1.jpg',
      gradientStart: Color(0xFF9B4F96),
      gradientEnd: Color(0xFFBF7BB6),
      primaryColor: Color(0xFF9B4F96),
      accentColor: Color(0xFFBF7BB6),
    ),
    AppThemeDefinition(
      key: 'blue',
      displayName: 'Blue',
      backgroundImage: 'bg2.jpg',
      gradientStart: Color(0xFF5B8DBE),
      gradientEnd: Color(0xFF85AED6),
      primaryColor: Color(0xFF5B8DBE),
      accentColor: Color(0xFF85AED6),
    ),
    AppThemeDefinition(
      key: 'green',
      displayName: 'Green',
      backgroundImage: 'bg3.jpg',
      gradientStart: Color(0xFF4A8B47),
      gradientEnd: Color(0xFF6FAA6B),
      primaryColor: Color(0xFF4A8B47),
      accentColor: Color(0xFF6FAA6B),
    ),
    AppThemeDefinition(
      key: 'slate',
      displayName: 'Slate',
      backgroundImage: 'bg4.jpg',
      gradientStart: Color(0xFF3A5266),
      gradientEnd: Color(0xFF5A7285),
      primaryColor: Color(0xFF3A5266),
      accentColor: Color(0xFF5A7285),
    ),
    AppThemeDefinition(
      key: 'burgundy',
      displayName: 'Burgundy',
      backgroundImage: 'bg5.jpg',
      gradientStart: Color(0xFF8B3A47),
      gradientEnd: Color(0xFFA85965),
      primaryColor: Color(0xFF8B3A47),
      accentColor: Color(0xFFA85965),
    ),
    AppThemeDefinition(
      key: 'mauve',
      displayName: 'Mauve',
      backgroundImage: 'bg6.jpg',
      gradientStart: Color(0xFF8B5580),
      gradientEnd: Color(0xFFAA789D),
      primaryColor: Color(0xFF8B5580),
      accentColor: Color(0xFFAA789D),
    ),
    AppThemeDefinition(
      key: 'sage',
      displayName: 'Sage',
      backgroundImage: 'bg7.jpg',
      gradientStart: Color(0xFF5F8160),
      gradientEnd: Color(0xFF7D9D7E),
      primaryColor: Color(0xFF5F8160),
      accentColor: Color(0xFF7D9D7E),
    ),
    AppThemeDefinition(
      key: 'tan',
      displayName: 'Tan',
      backgroundImage: 'bg8.jpg',
      gradientStart: Color(0xFF9B7350),
      gradientEnd: Color(0xFFB8916D),
      primaryColor: Color(0xFF9B7350),
      accentColor: Color(0xFFB8916D),
    ),
  ];

  /// Get theme by key
  static AppThemeDefinition getThemeByKey(String key) {
    return themes.firstWhere(
      (theme) => theme.key == key,
      orElse: () => themes.firstWhere((theme) => theme.key == defaultThemeKey),
    );
  }

  /// Get default theme
  static AppThemeDefinition get defaultTheme => getThemeByKey(defaultThemeKey);

  /// Get all theme keys
  static List<String> get themeKeys => themes.map((t) => t.key).toList();
}
