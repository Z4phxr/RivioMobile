import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/app_theme_storage_service.dart';
import '../theme/app_theme_definition.dart';

/// Notifier for managing app theme selection
class AppThemeNotifier extends StateNotifier<AppThemeDefinition> {
  final AppThemeStorageService storageService;

  AppThemeNotifier(this.storageService) : super(AppThemeRegistry.defaultTheme) {
    _loadTheme();
  }

  /// Load theme from storage on app start
  Future<void> _loadTheme() async {
    final themeKey = await storageService.getSelectedThemeKey();
    state = AppThemeRegistry.getThemeByKey(themeKey);
  }

  /// Set new theme and persist selection
  Future<void> setTheme(String themeKey) async {
    final theme = AppThemeRegistry.getThemeByKey(themeKey);
    await storageService.saveSelectedThemeKey(themeKey);
    state = theme;
  }

  /// Get current theme key
  String get currentThemeKey => state.key;
}

/// Provider for app theme
final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, AppThemeDefinition>((ref) {
      final storageService = ref.watch(appThemeStorageServiceProvider);
      return AppThemeNotifier(storageService);
    });
