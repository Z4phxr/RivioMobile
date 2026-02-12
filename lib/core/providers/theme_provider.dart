import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/theme_storage_service.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final ThemeStorageService storageService;

  ThemeModeNotifier(this.storageService) : super(ThemeMode.light) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await storageService.getThemeMode();
    state = themeMode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await storageService.saveThemeMode(mode);
    state = mode;
  }

  Future<void> toggle() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final storageService = ref.watch(themeStorageServiceProvider);
  return ThemeModeNotifier(storageService);
});
