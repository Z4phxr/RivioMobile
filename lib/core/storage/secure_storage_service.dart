import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SecureStorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  // Expose storage for PIN service
  FlutterSecureStorage get storage => _secureStorage;

  // Use SharedPreferences for web, SecureStorage for mobile
  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  // Token Management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _write('access_token', accessToken),
      _write('refresh_token', refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    return await _read('access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _read('refresh_token');
  }

  Future<TokenPair?> getTokens() async {
    final results = await Future.wait([
      _read('access_token'),
      _read('refresh_token'),
    ]);

    final access = results[0];
    final refresh = results[1];

    if (access == null || refresh == null) return null;

    return TokenPair(access: access, refresh: refresh);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _delete('access_token'),
      _delete('refresh_token'),
    ]);
  }

  Future<bool> hasTokens() async {
    final tokens = await getTokens();
    return tokens != null;
  }
}

class TokenPair {
  final String access;
  final String refresh;

  const TokenPair({
    required this.access,
    required this.refresh,
  });
}

// Provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
