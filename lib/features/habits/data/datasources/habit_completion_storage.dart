import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to persist habit completion state across sessions
class HabitCompletionStorageService {
  static const String _key = 'habit_completions';

  /// Save completion state to local storage
  Future<void> saveCompletions(Map<String, bool> completions) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(completions);
    await prefs.setString(_key, json);
  }

  /// Load completion state from local storage
  Future<Map<String, bool>> loadCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return {};

    try {
      final Map<String, dynamic> decoded = jsonDecode(json);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      return {};
    }
  }

  /// Clear all stored completions (call on logout)
  Future<void> clearCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
