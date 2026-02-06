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
      gradientStart: Color(0xFFb07fa5),
      gradientEnd: Color(0xFFc29ab6),
      primaryColor: Color(0xFFb07fa5),
      accentColor: Color(0xFFc29ab6),
    ),
    AppThemeDefinition(
      key: 'blue',
      displayName: 'Blue',
      backgroundImage: 'bg2.jpg',
      gradientStart: Color(0xFF7c9bb2),
      gradientEnd: Color(0xFF9ab1c4),
      primaryColor: Color(0xFF7c9bb2),
      accentColor: Color(0xFF9ab1c4),
    ),
    AppThemeDefinition(
      key: 'green',
      displayName: 'Green',
      backgroundImage: 'bg3.jpg',
      gradientStart: Color(0xFF5f7e5c),
      gradientEnd: Color(0xFF7a9b74),
      primaryColor: Color(0xFF5f7e5c),
      accentColor: Color(0xFF7a9b74),
    ),
    AppThemeDefinition(
      key: 'slate',
      displayName: 'Slate',
      backgroundImage: 'bg4.jpg',
      gradientStart: Color(0xFF4a6177),
      gradientEnd: Color(0xFF6a7e94),
      primaryColor: Color(0xFF4a6177),
      accentColor: Color(0xFF6a7e94),
    ),
    AppThemeDefinition(
      key: 'burgundy',
      displayName: 'Burgundy',
      backgroundImage: 'bg5.jpg',
      gradientStart: Color(0xFF8b4e58),
      gradientEnd: Color(0xFFa6616d),
      primaryColor: Color(0xFF8b4e58),
      accentColor: Color(0xFFa6616d),
    ),
    AppThemeDefinition(
      key: 'mauve',
      displayName: 'Mauve',
      backgroundImage: 'bg6.jpg',
      gradientStart: Color(0xFF9b6d8c),
      gradientEnd: Color(0xFFb58da5),
      primaryColor: Color(0xFF9b6d8c),
      accentColor: Color(0xFFb58da5),
    ),
    AppThemeDefinition(
      key: 'sage',
      displayName: 'Sage',
      backgroundImage: 'bg7.jpg',
      gradientStart: Color(0xFF6f8b68),
      gradientEnd: Color(0xFF90a88a),
      primaryColor: Color(0xFF6f8b68),
      accentColor: Color(0xFF90a88a),
    ),
    AppThemeDefinition(
      key: 'tan',
      displayName: 'Tan',
      backgroundImage: 'bg8.jpg',
      gradientStart: Color(0xFF92775d),
      gradientEnd: Color(0xFFaa947b),
      primaryColor: Color(0xFF92775d),
      accentColor: Color(0xFFaa947b),
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
