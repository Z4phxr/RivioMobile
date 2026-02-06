import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and managing the app PIN.
/// PIN is stored encrypted using flutter_secure_storage.
class PinStorageService {
  static const String _pinKey = 'app_pin';
  final FlutterSecureStorage _secureStorage;

  PinStorageService(this._secureStorage);

  /// Check if a PIN is currently set
  Future<bool> hasPinSet() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  /// Get the stored PIN (for verification purposes)
  Future<String?> getPin() async {
    return await _secureStorage.read(key: _pinKey);
  }

  /// Set a new PIN
  Future<void> setPin(String pin) async {
    if (pin.length != 4 || !_isNumeric(pin)) {
      throw ArgumentError('PIN must be exactly 4 digits');
    }
    await _secureStorage.write(key: _pinKey, value: pin);
  }

  /// Verify if provided PIN matches stored PIN
  Future<bool> verifyPin(String pin) async {
    final storedPin = await getPin();
    return storedPin == pin;
  }

  /// Remove the stored PIN
  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinKey);
  }

  /// Check if string contains only digits
  bool _isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }
}
