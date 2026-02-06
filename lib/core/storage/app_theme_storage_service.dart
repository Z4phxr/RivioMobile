import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme_definition.dart';

/// Service for persisting selected theme
class AppThemeStorageService {
  static const String _selectedThemeKey = 'selected_app_theme';

  /// Get selected theme key from storage
  Future<String> getSelectedThemeKey() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_selectedThemeKey);

    // Default to 'slate' theme as per requirements
    return stored ?? AppThemeRegistry.defaultThemeKey;
  }

  /// Save selected theme key to storage
  Future<void> saveSelectedThemeKey(String themeKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedThemeKey, themeKey);
  }
}

/// Provider for theme storage service
final appThemeStorageServiceProvider = Provider<AppThemeStorageService>((ref) {
  return AppThemeStorageService();
});
